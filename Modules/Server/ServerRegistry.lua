-- Modules/Server/ServerRegistry.lua
-- Reads active servers registered by ServerHeartbeat via MemoryStore Map + SortedMap index

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "ServerRegistry must be required on the server")

local MemoryStoreService = game:GetService("MemoryStoreService")

local ServerRegistry = {}
ServerRegistry.__index = ServerRegistry

function ServerRegistry.new(name)
    local self = setmetatable({}, ServerRegistry)
    self._name = tostring(name or "uf:hb")
    self._map = MemoryStoreService:GetMap(self._name)
    self._sorted = MemoryStoreService:GetSortedMap(self._name..":idx")
    return self
end

-- List recent active servers.
-- maxAgeSec: consider entries not older than this many seconds (default 120)
-- limit: maximum servers to return (default 50)
function ServerRegistry:listActive(maxAgeSec, limit)
    maxAgeSec = tonumber(maxAgeSec) or 120
    limit = tonumber(limit) or 50
    local now = os.time()
    local minTs = now - maxAgeSec
    local items = {}
    local ok, page = pcall(function()
        return self._sorted:GetRangeAsync(false, limit, minTs, now + 3600)
    end)
    if not ok or not page then return {} end
    for _, entry in ipairs(page) do
        local key = entry.key
        local record
        pcall(function()
            record = self._map:GetAsync(key)
        end)
        if record then
            record.jobId = record.jobId or key
            table.insert(items, record)
        end
    end
    return items
end

return ServerRegistry
