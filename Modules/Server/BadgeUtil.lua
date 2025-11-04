-- BadgeUtil.lua
-- Helpers to check/award badges with retries

local RunService = game:GetService("RunService")
local BadgeService = game:GetService("BadgeService")
assert(RunService:IsServer(), "BadgeUtil must be used on the server")

local DEFAULT_RETRIES = 2
local DEFAULT_BACKOFF = 1

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

local function getUserId(p)
	if typeof(p) == "Instance" and p:IsA("Player") then return p.UserId end
	return p
end

local M = {}

function M.hasBadge(userIdOrPlayer, badgeId)
	local userId = getUserId(userIdOrPlayer)
	return retry(function()
		return true, BadgeService:UserHasBadgeAsync(userId, badgeId)
	end)
end

function M.awardIfNotOwned(userIdOrPlayer, badgeId)
	local userId = getUserId(userIdOrPlayer)
	local hasOk, has = M.hasBadge(userId, badgeId)
	if hasOk and has then
		return true, "owned"
	end
	local ok, res = retry(function()
		BadgeService:AwardBadge(userId, badgeId)
		return true
	end)
	return ok, res
end

return M
