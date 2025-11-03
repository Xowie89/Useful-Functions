-- RateLimiter.lua
-- Token bucket rate limiter per key
-- API:
--   RateLimiter.new(capacity: number, refillPerSecond: number) -> limiter
--   limiter:allow(key: string, tokens?: number) -> (boolean allowed, number remaining)
--   limiter:setCapacity(capacity), limiter:setRefillPerSecond(rate)
--   limiter:getState(key) -> { tokens: number, last: number }

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type Limiter = {
	allow: (self: Limiter, key: string, tokens: number?) -> (boolean, number),
	setCapacity: (self: Limiter, capacity: number) -> (),
	setRefillPerSecond: (self: Limiter, rate: number) -> (),
	getState: (self: Limiter, key: string) -> { tokens: number, last: number },
}

local function clamp(x, a, b)
	if x < a then return a end
	if x > b then return b end
	return x
end

function RateLimiter.new(capacity: number, refillPerSecond: number): Limiter
	local self = setmetatable({}, RateLimiter)
	self._capacity = math.max(0, capacity or 1)
	self._refill = math.max(0, refillPerSecond or 1)
	self._buckets = {} -- key -> { tokens: number, last: number }
	return self :: any
end

local function refill(self, key)
	local bucket = self._buckets[key]
	local now = os.clock()
	if not bucket then
		bucket = { tokens = self._capacity, last = now }
		self._buckets[key] = bucket
		return bucket
	end
	local elapsed = math.max(0, now - bucket.last)
	if elapsed > 0 and self._refill > 0 then
		bucket.tokens = clamp(bucket.tokens + elapsed * self._refill, 0, self._capacity)
		bucket.last = now
	end
	return bucket
end

function RateLimiter:allow(key: string, tokens: number?): (boolean, number)
	tokens = tokens or 1
	if tokens <= 0 then return true, self._capacity end
	local bucket = refill(self, key)
	if bucket.tokens >= tokens then
		bucket.tokens -= tokens
		return true, bucket.tokens
	end
	return false, bucket.tokens
end

function RateLimiter:setCapacity(capacity: number)
	self._capacity = math.max(0, capacity)
	for _, bucket in pairs(self._buckets) do
		bucket.tokens = clamp(bucket.tokens, 0, self._capacity)
	end
end

function RateLimiter:setRefillPerSecond(rate: number)
	self._refill = math.max(0, rate)
end

function RateLimiter:getState(key: string)
	local b = refill(self, key)
	return { tokens = b.tokens, last = b.last }
end

return RateLimiter