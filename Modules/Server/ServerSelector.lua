-- Modules/Server/ServerSelector.lua
-- Helper to build a public-server selector for MatchmakingUtil "public" routing

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "ServerSelector must be required on the server")

local ServerRegistry = require(script.Parent.ServerRegistry)

-- makePublicServerSelector
-- Returns a selector function players->{jobId|string?} that chooses a public server.
-- opts:
--   registryName?: string (default "uf:hb")
--   maxAgeSec?: number (default 120)
--   limit?: number (default 50)
--   capacityFn?: (record: { players:number, private:boolean }, partySize:number)->boolean (default: always true)
--   region?: string (optional; if records have record.region, filter to this)
--   tieBreaker?: (a: table, b: table)->boolean (return true if a is preferred)
-- Notes:
--   - Records are provided by ServerHeartbeat via MemoryStore and read via ServerRegistry.
--   - Default strategy chooses lowest player count among public servers, then newer ts.
local function makePublicServerSelector(opts)
    opts = opts or {}
    local registryName = opts.registryName or "uf:hb"
    local maxAgeSec = tonumber(opts.maxAgeSec) or 120
    local limit = tonumber(opts.limit) or 50
    local capacityFn = opts.capacityFn or function(_record, _partySize) return true end
    local desiredRegion = opts.region
    local tieBreaker = opts.tieBreaker or function(a, b)
        if a.players ~= b.players then
            return a.players < b.players -- prefer lower load
        end
        return (a.ts or 0) > (b.ts or 0) -- prefer fresher
    end

    local registry = ServerRegistry.new(registryName)

    return function(players)
        local partySize = typeof(players) == "table" and #players or 1
        local list = registry:listActive(maxAgeSec, limit)
        if not list or #list == 0 then return nil end

        -- Filter to public, fresh, and optional region
        local candidates = {}
        for _, rec in ipairs(list) do
            if not rec.private then
                if not desiredRegion or rec.region == desiredRegion then
                    if capacityFn(rec, partySize) ~= false then
                        table.insert(candidates, rec)
                    end
                end
            end
        end
        if #candidates == 0 then return nil end

        table.sort(candidates, function(a, b)
            return tieBreaker(a, b)
        end)

        local chosen = candidates[1]
        return chosen and chosen.jobId or nil
    end
end

return {
    makePublicServerSelector = makePublicServerSelector,
}
