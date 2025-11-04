-- MarketplaceUtil.lua
-- Helpers for game passes and developer products (prompt + receipt routing)

local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
assert(RunService:IsServer(), "MarketplaceUtil must be used on the server")

local M = {}

-- Check if a player owns a game pass
function M.ownsGamePass(player, gamePassId)
	local ok, res = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, gamePassId)
	if not ok then return false, res end
	return true, res
end

-- Prompt purchase of a game pass for a player
function M.promptGamePass(player, gamePassId)
	MarketplaceService:PromptGamePassPurchase(player, gamePassId)
end

-- Prompt a developer product for a player
function M.promptProduct(player, productId)
	MarketplaceService:PromptProductPurchase(player, productId)
end

-- Simple receipt router: map productId -> handler(player, receiptInfo)
-- handler should return Enum.ProductPurchaseDecision.PurchaseGranted or NotProcessedYet
-- Usage:
--   local router = MarketplaceUtil.createReceiptRouter({ [123]=function(player, r) return Enum.ProductPurchaseDecision.PurchaseGranted end })
--   MarketplaceUtil.bindProcessReceipt(router)
function M.createReceiptRouter(map)
	return function(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local handler = map[receiptInfo.ProductId]
		if handler then
			local ok, decision = pcall(handler, player, receiptInfo)
			if ok and decision then
				return decision
			end
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function M.bindProcessReceipt(fn)
	MarketplaceService.ProcessReceipt = fn
end

return M
