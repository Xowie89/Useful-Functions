-- Modules/Server/ServerHeartbeat.lua
-- Periodically publishes a heartbeat to MemoryStore (map) for liveness tracking

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "ServerHeartbeat must be required on the server")

local MemoryStoreService = game:GetService("MemoryStoreService")
local HttpService = game:GetService("HttpService")

local function jobId()
    return game.JobId or "unknown"
end

local ServerHeartbeat = {}
ServerHeartbeat.__index = ServerHeartbeat

function ServerHeartbeat.new(name, ttlSeconds)
    local self = setmetatable({}, ServerHeartbeat)
    self._name = tostring(name or "uf:hb")
    self._ttl = tonumber(ttlSeconds) or 60
    self._running = false
    self._thread = nil
    self._map = MemoryStoreService:GetMap(self._name)
    self._sorted = MemoryStoreService:GetSortedMap(self._name..":idx")
    return self
end

function ServerHeartbeat:_beat()
    local payload = {
        jobId = jobId(),
        placeId = game.PlaceId,
        ts = os.time(),
        players = #game:GetService("Players"):GetPlayers(),
        private = game.PrivateServerId ~= "",
    }
    local key = tostring(jobId())
    local ok, err = pcall(function()
        self._map:SetAsync(key, payload, self._ttl)
        self._sorted:SetAsync(key, payload.ts, self._ttl)
    end)
    if not ok then
        warn("ServerHeartbeat SetAsync failed:", err)
    end
end

function ServerHeartbeat:start(intervalSeconds)
    if self._running then return end
    self._running = true
    local interval = math.max(5, tonumber(intervalSeconds) or 15)
    self._thread = task.spawn(function()
        while self._running do
            self:_beat()
            task.wait(interval)
        end
    end)
end

function ServerHeartbeat:stop()
    self._running = false
end

return ServerHeartbeat
