-- GroupUtil.lua
-- Helpers for group membership, rank, and role lookups

local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
assert(RunService:IsServer(), "GroupUtil must be used on the server")

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

-- Returns role string or nil
function M.getRoleInGroup(userIdOrPlayer, groupId)
	local userId = getUserId(userIdOrPlayer)
	local ok, groupsOrErr = retry(function()
		return true, GroupService:GetGroupsAsync(userId)
	end)
	if not ok then return nil, groupsOrErr end
	for _, info in ipairs(groupsOrErr) do
		if info.Id == groupId then
			return info.Role, nil
		end
	end
	return nil, nil
end

-- Returns rank number or 0 if not in group
function M.getRankInGroup(userIdOrPlayer, groupId)
	local userId = getUserId(userIdOrPlayer)
	local ok, groupsOrErr = retry(function()
		return true, GroupService:GetGroupsAsync(userId)
	end)
	if not ok then return 0, groupsOrErr end
	for _, info in ipairs(groupsOrErr) do
		if info.Id == groupId then
			return info.Rank or 0, nil
		end
	end
	return 0, nil
end

function M.isInGroup(userIdOrPlayer, groupId, minRank)
	local rank = M.getRankInGroup(userIdOrPlayer, groupId)
	if type(rank) ~= "number" then return false end
	if minRank then
		return rank >= minRank
	end
	return rank > 0
end

return M
