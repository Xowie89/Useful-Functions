-- MessagingServiceUtil.lua
-- Lightweight helpers for publish/subscribe with retries and safe handlers

local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")
assert(RunService:IsServer(), "MessagingServiceUtil must be used on the server")

local DEFAULT_RETRIES = 3
local DEFAULT_BACKOFF = 1

local function sleep(sec)
	if sec and sec > 0 then task.wait(sec) end
end

local function retry(op, retries, backoff)
	retries = retries or DEFAULT_RETRIES
	backoff = backoff or DEFAULT_BACKOFF
	local lastErr
	for i = 1, math.max(1, retries + 1) do
		local ok, res = pcall(op)
		if ok then return true, res end
		lastErr = res
		if i <= retries then sleep(backoff * (2 ^ (i - 1))) end
	end
	return false, lastErr
end

local M = {}

-- Publish a message to a topic with retries
function M.publish(topic, data, opts)
	assert(type(topic) == "string" and #topic > 0, "publish: topic must be a non-empty string")
	opts = opts or {}
	local retries = opts.retries or DEFAULT_RETRIES
	local backoff = opts.backoff or DEFAULT_BACKOFF
	return retry(function()
		MessagingService:PublishAsync(topic, data)
		return true
	end, retries, backoff)
end

-- Subscribe to a topic; returns a connection with :Disconnect()
-- opts = { safe = true } when true wraps handler in pcall
function M.subscribe(topic, handler, opts)
	assert(type(topic) == "string" and #topic > 0, "subscribe: topic must be a non-empty string")
	assert(type(handler) == "function", "subscribe: handler must be a function")
	opts = opts or { safe = true }
	local conn = MessagingService:SubscribeAsync(topic, function(message)
		if opts.safe ~= false then
			local ok, err = pcall(handler, message.Data, message)
			if not ok then warn("MessagingService handler error:", err) end
		else
			handler(message.Data, message)
		end
	end)
	return conn
end

return M
