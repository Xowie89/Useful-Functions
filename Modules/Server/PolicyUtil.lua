-- PolicyUtil.lua
-- Wrappers for PolicyService to read player policy flags

local RunService = game:GetService("RunService")
local PolicyService = game:GetService("PolicyService")
assert(RunService:IsServer(), "PolicyUtil must be used on the server")

local M = {}

-- Returns policy table or nil, err
function M.getPolicy(player)
	local ok, policy = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
	if not ok then return nil, policy end
	return policy, nil
end

-- Convenience accessors (nil if unknown)
function M.arePaidRandomItemsRestricted(player)
	local p = M.getPolicy(player)
	if type(p) == "table" then
		return p.ArePaidRandomItemsRestricted
	end
	return nil
end

function M.isSubjectToChinaPolicies(player)
	local p = M.getPolicy(player)
	if type(p) == "table" then
		return p.IsSubjectToChinaPolicies
	end
	return nil
end

function M.isVoiceEnabled(player)
	local p = M.getPolicy(player)
	if type(p) == "table" then
		return p.IsVoiceChatAllowed
	end
	return nil
end

return M
