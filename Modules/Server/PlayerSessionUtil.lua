-- Modules/Server/PlayerSessionUtil.lua
-- Track basic player session info (start/end times, duration), optional hooks

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
assert(RunService:IsServer(), "PlayerSessionUtil must be required on the server")

local PlayerSessionUtil = {}
PlayerSessionUtil.__index = PlayerSessionUtil

local function now() return os.time() end

function PlayerSessionUtil.new()
	local self = setmetatable({}, PlayerSessionUtil)
	self._sessions = {} -- [player] = { startedAt:number, lastSeen:number }
	self._bound = false
	self._conns = {}
	self._onStart = Instance.new("BindableEvent")
	self._onEnd = Instance.new("BindableEvent")
	return self
end

function PlayerSessionUtil:onStart(cb)
	return self._onStart.Event:Connect(cb)
end

function PlayerSessionUtil:onEnd(cb)
	return self._onEnd.Event:Connect(cb)
end

function PlayerSessionUtil:get(player)
	local s = self._sessions[player]
	if not s then return nil end
	return {
		startedAt = s.startedAt,
		lastSeen = s.lastSeen,
		durationSec = function()
			return math.max(0, (s.lastSeen or s.startedAt or now()) - (s.startedAt or now()))
		end,
	}
end

function PlayerSessionUtil:_handleAdded(player)
	local entry = { startedAt = now(), lastSeen = now() }
	self._sessions[player] = entry
	self._onStart:Fire(player, entry)
	-- heartbeat update lastSeen
	local conn = game:GetService("RunService").Heartbeat:Connect(function()
		entry.lastSeen = now()
	end)
	self._conns[player] = conn
end

function PlayerSessionUtil:_handleRemoving(player)
	local entry = self._sessions[player]
	if entry then
		self._onEnd:Fire(player, entry)
		self._sessions[player] = nil
	end
	local conn = self._conns[player]
	if conn then conn:Disconnect() end
	self._conns[player] = nil
end

-- Bind to Players to automatically track sessions. Returns unbind function.
function PlayerSessionUtil:bind()
	if self._bound then return function() end end
	self._bound = true
	local added = Players.PlayerAdded:Connect(function(plr)
		self:_handleAdded(plr)
	end)
	local removing = Players.PlayerRemoving:Connect(function(plr)
		self:_handleRemoving(plr)
	end)
	-- Attach to existing players if any
	for _, plr in ipairs(Players:GetPlayers()) do
		self:_handleAdded(plr)
	end
	return function()
		if added.Connected then added:Disconnect() end
		if removing.Connected then removing:Disconnect() end
		self._bound = false
	end
end

function PlayerSessionUtil:destroy()
	for plr, _ in pairs(self._sessions) do
		self:_handleRemoving(plr)
	end
	self._onStart:Destroy()
	self._onEnd:Destroy()
end

return PlayerSessionUtil
