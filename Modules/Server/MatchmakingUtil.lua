-- MatchmakingUtil.lua
-- Server-side matchmaking with priorities, constraints, timeouts, and optional dry-run
-- API (server):
--   local mm = MatchmakingUtil.new(placeId:number, partySize:number, opts?)
--   mm:enqueue(player, opts?)  -- opts: { priority?: number, role?: string, region?: string, timeoutSec?: number, meta?: table }
--   mm:dequeue(player); mm:size() -> number; mm:flush()
--   mm:onMatched(callback(players:{Player})) -> RBXScriptConnection -- fired when a party is formed (before teleport)
--   mm:onTimeout(callback(player: Player)) -> RBXScriptConnection -- fired when a queued player times out
--   mm:destroy()
-- opts: {
--   retries?: number=2, backoff?: number=1, pollSeconds?: number=2,
--   priorityAgingPerSecond?: number=0, -- how much priority increases per second waited (fairness)
--   dryRun?: boolean=false,            -- if true, do not call TeleportService (used in tests)
--   constraints?: {
--     groupBy?: string|((entry)->any), -- e.g. "region" or function(entry)->key
--     requireRoles?: { [string]: number }, -- e.g. { Tank=1, Healer=1 }
--     predicate?: (entry)->boolean,         -- filter eligible entries
--     compatibility?: (a, b)->boolean       -- pairwise compatibility
--   }
-- }

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TeleportUtil = require(script.Parent.TeleportUtil)
local Signal = require(ReplicatedStorage:WaitForChild("Modules").Signal)

local MatchmakingUtil = {}
MatchmakingUtil.__index = MatchmakingUtil

function MatchmakingUtil.new(placeId: number, partySize: number, opts)
	assert(RunService:IsServer(), "MatchmakingUtil must be used on the server")
	opts = opts or {}
	local self = setmetatable({}, MatchmakingUtil)
	self._placeId = placeId
	self._partySize = math.max(1, partySize or 1)
	self._retries = opts.retries or 2
	self._backoff = opts.backoff or 1
	self._queue = {} -- { { player:Player, priority:number, enqueued:number, timeoutAt?:number, role?:string, region?:string, meta?:table } }
	self._matched = Signal.new()
	self._timedOut = Signal.new()
	self._pollSeconds = opts.pollSeconds or 2
	self._running = true
	self._aging = opts.priorityAgingPerSecond or 0
	self._dryRun = opts.dryRun or false
	self._constraints = opts.constraints or {}
	self._teleportStrategy = (opts.teleportStrategy == "public") and "public" or "private"
	self._serverSelector = opts.serverSelector -- function(players:{Player})->jobId?

	self._playerRemovingConn = Players.PlayerRemoving:Connect(function(p)
		self:dequeue(p)
	end)

	-- Background poller
	task.spawn(function()
		while self._running do
			self:_process()
			task.wait(self._pollSeconds)
		end
	end)

	return self
end

function MatchmakingUtil:destroy()
	self._running = false
	if self._playerRemovingConn then self._playerRemovingConn:Disconnect() end
	self._matched:Destroy()
	self._timedOut:Destroy()
	self._queue = {}
end

function MatchmakingUtil:onMatched(callback)
	return self._matched:Connect(callback)
end

function MatchmakingUtil:onTimeout(callback)
    return self._timedOut:Connect(callback)
end

function MatchmakingUtil:enqueue(player: Player, opts)
	opts = opts or {}
	-- Already queued? no-op
	for _, e in ipairs(self._queue) do if e.player == player then return end end
	local now = os.clock()
	local entry = {
		player = player,
		priority = opts.priority or 0,
		enqueued = now,
		timeoutAt = opts.timeoutSec and (now + math.max(0, opts.timeoutSec)) or nil,
		role = opts.role,
		region = opts.region,
		meta = opts.meta,
	}
	table.insert(self._queue, entry)
end

function MatchmakingUtil:dequeue(player: Player)
    for i = #self._queue, 1, -1 do
        if self._queue[i].player == player then table.remove(self._queue, i) return end
    end
end

function MatchmakingUtil:size()
	return #self._queue
end

-- Compute group key per constraints
local function getGroupKey(entry, constraints)
	local g = constraints.groupBy
	if type(g) == "function" then
		return g(entry)
	elseif type(g) == "string" then
		if g == "region" then return entry.region or (entry.meta and entry.meta.region) end
		if g == "role" then return entry.role or (entry.meta and entry.meta.role) end
		return (entry.meta and entry.meta[g])
	end
	return nil
end

local function isPlayerInstance(p)
	return typeof(p) == "Instance" and p:IsA("Player")
end

function MatchmakingUtil:_cleanupExpired()
	local now = os.clock()
	for i = #self._queue, 1, -1 do
		local e = self._queue[i]
		if e.timeoutAt and e.timeoutAt <= now then
			table.remove(self._queue, i)
			self._timedOut:Fire(e.player)
		end
	end
end

function MatchmakingUtil:_effectivePriority(entry, now)
	return (entry.priority or 0) + self._aging * math.max(0, now - (entry.enqueued or now))
end

function MatchmakingUtil:_pickParty()
	local now = os.clock()
	-- Build candidate list (filter invalid players and by predicate if provided)
	local cand = {}
	local pred = self._constraints.predicate
	for _, e in ipairs(self._queue) do
		if not isPlayerInstance(e.player) or Players:FindFirstChild(e.player.Name) ~= nil or self._dryRun then
			if not pred or pred(e) then
				table.insert(cand, e)
			end
		end
	end
	if #cand < self._partySize then return nil end

	table.sort(cand, function(a, b)
		local ea = self:_effectivePriority(a, now)
		local eb = self:_effectivePriority(b, now)
		if ea ~= eb then return ea > eb end
		return (a.enqueued or 0) < (b.enqueued or 0)
	end)

	local compat = self._constraints.compatibility
	local requireRoles = self._constraints.requireRoles
	local groupBy = self._constraints.groupBy

	local function rolesSatisfied(sel)
		if not requireRoles then return true end
		local counts = {}
		for _, e in ipairs(sel) do
			local r = e.role or (e.meta and e.meta.role)
			if r then counts[r] = (counts[r] or 0) + 1 end
		end
		for role, need in pairs(requireRoles) do
			if (counts[role] or 0) < need then return false end
		end
		return #sel == self._partySize
	end

	local function tryBuild(from)
		local selected = {}
		local needed = {}
		if requireRoles then for k, v in pairs(requireRoles) do needed[k] = v end end
		local groupKey = groupBy and getGroupKey(from[1], self._constraints) or nil
		for _, e in ipairs(from) do
			if #selected >= self._partySize then break end
			if groupKey ~= nil and getGroupKey(e, self._constraints) ~= groupKey then
				continue
			end
			local okRole = true
			if requireRoles then
				local r = e.role or (e.meta and e.meta.role)
				if r and needed[r] and needed[r] > 0 then
					needed[r] -= 1
				else
					-- allow as filler only if all needed are satisfied or role not constrained
					local anyNeeded = false
					for _, v in pairs(needed) do if v > 0 then anyNeeded = true break end end
					if anyNeeded then okRole = false end
				end
			end
			if okRole then
				local okCompat = true
				if compat then
					for _, s in ipairs(selected) do
						if not compat(e, s) then okCompat = false break end
					end
				end
				if okCompat then table.insert(selected, e) end
			end
		end
		if #selected == self._partySize and rolesSatisfied(selected) then
			return selected
		end
		return nil
	end

	if groupBy then
		-- Iterate each group's ordering by first appearance in sorted list
		local seen = {}
		local groups = {}
		for _, e in ipairs(cand) do
			local k = getGroupKey(e, self._constraints)
			if k ~= nil and not seen[k] then
				seen[k] = true
				local bucket = {}
				for _, x in ipairs(cand) do if getGroupKey(x, self._constraints) == k then table.insert(bucket, x) end end
				table.insert(groups, bucket)
			end
		end
		-- Also consider no-key bucket if some entries lack the key
		local nog = {}
		for _, e in ipairs(cand) do if getGroupKey(e, self._constraints) == nil then table.insert(nog, e) end end
		if #nog > 0 then table.insert(groups, nog) end
		for _, bucket in ipairs(groups) do
			local sel = tryBuild(bucket)
			if sel then return sel end
		end
		return nil
	else
		-- No grouping, build from all candidates
		return tryBuild(cand)
	end
end

function MatchmakingUtil:flush()
	self:_process()
end

function MatchmakingUtil:_process()
	-- Clean up timeouts first
	self:_cleanupExpired()
	while true do
		local partyEntries = self:_pickParty()
		if not partyEntries then break end
		local players = {}
		local selectedSet = {}
		for _, e in ipairs(partyEntries) do
			table.insert(players, e.player)
			selectedSet[e] = true
		end

		-- Fire callback for external bookkeeping
		self._matched:Fire(players)

		local ok = true
		local errMsg
		if not self._dryRun then
			if self._teleportStrategy == "public" then
				local jobId
				if typeof(self._serverSelector) == "function" then
					local okSelect, jidOrErr = pcall(self._serverSelector, players)
					if okSelect then jobId = jidOrErr else warn("serverSelector error:", jidOrErr) end
				end
				if jobId and type(jobId) == "string" then
					ok, errMsg = TeleportUtil.teleportToPlaceInstance(self._placeId, jobId, players, { matchmaking = true }, { retries = self._retries, backoff = self._backoff })
				else
					ok, errMsg = false, "no jobId from serverSelector"
				end
			else
				ok, errMsg = TeleportUtil.teleportToPrivateServer(self._placeId, players, { matchmaking = true }, { retries = self._retries, backoff = self._backoff })
			end
		end
		if ok then
			-- Remove selected entries from queue
			local newQ = {}
			for _, e in ipairs(self._queue) do if not selectedSet[e] then table.insert(newQ, e) end end
			self._queue = newQ
		else
			warn("Matchmaking teleport failed:", errMsg)
			-- Do not remove; break to retry later
			break
		end
	end
end

return MatchmakingUtil