-- MatchmakingUtil.lua
-- Server-side simple matchmaking queue that forms parties and teleports via TeleportUtil
-- API (server):
--   local mm = MatchmakingUtil.new(placeId:number, partySize:number, opts?)
--   mm:enqueue(player), mm:dequeue(player), mm:size() -> number, mm:flush() -- forces processing
--   mm:onMatched(callback(players:{Player})) -> RBXScriptConnection -- called before teleport
-- opts: { retries:number?=2, backoff:number?=1, pollSeconds:number?=2 }

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
	self._queue = {} -- {Player}
	self._matched = Signal.new()
	self._pollSeconds = opts.pollSeconds or 2
	self._running = true

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
	self._queue = {}
end

function MatchmakingUtil:onMatched(callback)
	return self._matched:Connect(callback)
end

function MatchmakingUtil:enqueue(player: Player)
	for _, p in ipairs(self._queue) do if p == player then return end end
	table.insert(self._queue, player)
end

function MatchmakingUtil:dequeue(player: Player)
	for i, p in ipairs(self._queue) do
		if p == player then table.remove(self._queue, i) return end
	end
end

function MatchmakingUtil:size()
	return #self._queue
end

function MatchmakingUtil:_process()
	while #self._queue >= self._partySize do
		local party = {}
		for i = 1, self._partySize do
			party[i] = table.remove(self._queue, 1)
		end
		-- Fire callback for external bookkeeping
		self._matched:Fire(party)
		-- Teleport to private server
		local ok, err = TeleportUtil.teleportToPrivateServer(self._placeId, party, { matchmaking = true }, { retries = self._retries, backoff = self._backoff })
		if not ok then
			warn("Matchmaking teleport failed:", err)
			-- Push players back to front of queue if failure
			for i = #party, 1, -1 do table.insert(self._queue, 1, party[i]) end
			break
		end
	end
end

function MatchmakingUtil:flush()
	self:_process()
end

return MatchmakingUtil