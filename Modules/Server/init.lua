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

return M
