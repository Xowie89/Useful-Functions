-- ClientRateLimiter.lua
-- Thin wrapper around RateLimiter for client-side checks
-- API (client):
--   local rl = ClientRateLimiter.new(capacity, refillPerSecond)
--   rl:allow(key, tokens?) -> (boolean, remaining)
-- Note: client-side limiting is advisory; enforce on server for security.

local RunService = game:GetService("RunService")
local RateLimiter = require(script.Parent.Parent.RateLimiter)

local ClientRateLimiter = {}
ClientRateLimiter.__index = ClientRateLimiter

function ClientRateLimiter.new(capacity: number, refillPerSecond: number)
	assert(RunService:IsClient(), "ClientRateLimiter should be used on the client")
	local self = setmetatable({}, ClientRateLimiter)
	self._limiter = RateLimiter.new(capacity, refillPerSecond)
	return self
end

function ClientRateLimiter:allow(key: string, tokens: number?)
	return self._limiter:allow(key, tokens)
end

return ClientRateLimiter