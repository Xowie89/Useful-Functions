-- GlobalRateLimiter.lua
-- Distributed token-bucket rate limiter using MemoryStore SortedMap

local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
assert(RunService:IsServer(), "GlobalRateLimiter must be used on the server")

local MAP_NAME = "UF_GlobalRateLimiter"
local map = MemoryStoreService:GetSortedMap(MAP_NAME)

export type Bucket = { tokens: number, updated: number }

local GRL = {}
GRL.__index = GRL

function GRL.new(capacity: number, refillPerSecond: number)
    local self = setmetatable({}, GRL)
    self.capacity = capacity
    self.refill = refillPerSecond
    return self
end

local function now()
    return os.time()
end

-- Attempt to consume tokens (default 1) for a key globally. Returns ok, remainingTokens
function GRL:allow(key: string, tokens: number?): (boolean, number)
    tokens = tokens or 1
    local capacity = self.capacity
    local refill = self.refill
    local ttl = 60 -- keep buckets alive for 60s since last update

    local ok, remainingOrErr = pcall(function()
        return map:UpdateAsync(key, function(old: Bucket?)
            local t = now()
            local bucket: Bucket = old or { tokens = capacity, updated = t }
            local dt = math.max(0, t - (bucket.updated or t))
            local refilled = math.min(capacity, bucket.tokens + dt * refill)
            if refilled >= tokens then
                bucket.tokens = refilled - tokens
                bucket.updated = t
                return bucket
            else
                bucket.tokens = refilled
                bucket.updated = t
                return bucket
            end
        end, ttl)
    end)
    if not ok then return false, 0 end
    local bucket = remainingOrErr :: Bucket
    return (bucket.tokens <= (self.capacity - (tokens or 1))), bucket.tokens
end

function GRL:setCapacity(n: number) self.capacity = n end
function GRL:setRefillPerSecond(n: number) self.refill = n end

return GRL
