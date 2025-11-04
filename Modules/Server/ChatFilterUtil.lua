-- ChatFilterUtil.lua
-- Wrappers for TextService chat filtering (broadcast and per-user)

local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
assert(RunService:IsServer(), "ChatFilterUtil must be used on the server")

local DEFAULT_RETRIES = 2
local DEFAULT_BACKOFF = 0.5

local function sleep(sec) if sec and sec > 0 then task.wait(sec) end end

local function retry(op, retries, backoff)
	retries = retries or DEFAULT_RETRIES
	backoff = backoff or DEFAULT_BACKOFF
	local lastErr
	for i = 1, math.max(1, retries + 1) do
		local ok, res = pcall(op)
		if ok then return true, res end
		lastErr = res
		if i <= retries then sleep(backoff * i) end
	end
	return false, lastErr
end

local M = {}

-- filterForBroadcast(text, fromUserId) -> ok, filteredOrErr
function M.filterForBroadcast(text, fromUserId)
	assert(type(fromUserId) == "number", "fromUserId must be a number")
	local ok, res = retry(function()
		local result = TextService:FilterStringAsync(tostring(text or ""), fromUserId)
		return true, result:GetNonChatStringForBroadcastAsync()
	end)
	return ok, res
end

-- filterForUser(text, fromUserId, toUserId) -> ok, filteredOrErr
function M.filterForUser(text, fromUserId, toUserId)
	assert(type(fromUserId) == "number", "fromUserId must be a number")
	assert(type(toUserId) == "number", "toUserId must be a number")
	local ok, res = retry(function()
		local result = TextService:FilterStringAsync(tostring(text or ""), fromUserId)
		return true, result:GetChatForUserAsync(toUserId)
	end)
	return ok, res
end

return M
