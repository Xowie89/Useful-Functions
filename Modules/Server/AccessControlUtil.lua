-- AccessControlUtil.lua
-- Centralized access checks: allowlists, denylists, group rank, game pass, policy flags

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "AccessControlUtil must be used on the server")

local MarketplaceService = game:GetService("MarketplaceService")
local GroupService = game:GetService("GroupService")

local M = {}

local function setOf(list)
	local s = {}
	if type(list) == "table" then
		for _, v in ipairs(list) do s[v] = true end
	end
	return s
end

-- rules = {
--   allowUserIds = { ... },
--   denyUserIds = { ... },
--   group = { id = number, minRank = number? },
--   gamePassId = number?,
--   requireVoice = boolean?,
--   forbidPaidRandomItems = boolean?,
-- }
function M.canUseFeature(player, rules, deps)
	rules = rules or {}
	deps = deps or {}
	local PolicyUtil = deps.PolicyUtil or require(script.Parent.PolicyUtil)
	local GroupUtil = deps.GroupUtil or require(script.Parent.GroupUtil)
	local MarketplaceUtil = deps.MarketplaceUtil or require(script.Parent.MarketplaceUtil)

	local uid = player.UserId

	-- deny explicit
	local deny = setOf(rules.denyUserIds)
	if deny[uid] then return false, "denylist" end

	-- allow explicit
	local allow = setOf(rules.allowUserIds)
	if next(allow) ~= nil and not allow[uid] then return false, "not-allowlisted" end

	-- group gate
	if rules.group and rules.group.id then
		local rank = GroupUtil.getRankInGroup(player, rules.group.id)
		local min = rules.group.minRank or 1
		if type(rank) ~= "number" or rank < min then return false, "insufficient-group-rank" end
	end

	-- game pass gate
	if rules.gamePassId then
		local ok, owns = MarketplaceUtil.ownsGamePass(player, rules.gamePassId)
		if not ok then return false, "pass-check-failed" end
		if not owns then return false, "missing-pass" end
	end

	-- policy checks
	if rules.requireVoice == true then
		local v = PolicyUtil.isVoiceEnabled(player)
		if v == false then return false, "voice-disabled" end
	end
	if rules.forbidPaidRandomItems == true then
		local restricted = PolicyUtil.arePaidRandomItemsRestricted(player)
		if restricted == true then return false, "paid-random-items-restricted" end
	end

	return true
end

return M
