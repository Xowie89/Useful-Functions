-- Modules/Server/init.lua
-- Aggregates shared (from ReplicatedStorage.Modules) + server-only (sibling) utilities

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
assert(RunService:IsServer(), "Modules/Server/init must be required on the server")

local SharedRoot = ReplicatedStorage:WaitForChild("Modules")
local Shared = require(SharedRoot.Shared.init)

-- Shallow copy shared exports
local M = {}
for k, v in pairs(Shared) do M[k] = v end

-- Server-only modules live in this Server folder
M.TeleportUtil = require(script.Parent.TeleportUtil)
M.MatchmakingUtil = require(script.Parent.MatchmakingUtil)
M.HttpUtil = require(script.Parent.HttpUtil)
M.DataStoreUtil = require(script.Parent.DataStoreUtil)
M.LeaderstatsUtil = require(script.Parent.LeaderstatsUtil)
M.MessagingServiceUtil = require(script.Parent.MessagingServiceUtil)
M.MemoryStoreUtil = require(script.Parent.MemoryStoreUtil)
M.BadgeUtil = require(script.Parent.BadgeUtil)
M.GroupUtil = require(script.Parent.GroupUtil)
M.MarketplaceUtil = require(script.Parent.MarketplaceUtil)
M.PolicyUtil = require(script.Parent.PolicyUtil)
M.BanUtil = require(script.Parent.BanUtil)
M.WebhookUtil = require(script.Parent.WebhookUtil)
M.ChatFilterUtil = require(script.Parent.ChatFilterUtil)
M.AccessControlUtil = require(script.Parent.AccessControlUtil)
M.JobScheduler = require(script.Parent.JobScheduler)
M.AuditLogUtil = require(script.Parent.AuditLogUtil)
M.DistributedLockUtil = require(script.Parent.DistributedLockUtil)
M.GlobalRateLimiter = require(script.Parent.GlobalRateLimiter)
M.ServerMetricsUtil = require(script.Parent.ServerMetricsUtil)
M.CharacterScaleUtil = require(script.Parent.CharacterScaleUtil)
M.CharacterMovementUtil = require(script.Parent.CharacterMovementUtil)
M.CharacterAppearanceUtil = require(script.Parent.CharacterAppearanceUtil)
M.CharacterVisibilityUtil = require(script.Parent.CharacterVisibilityUtil)
M.CharacterHealthUtil = require(script.Parent.CharacterHealthUtil)

return M
