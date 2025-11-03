-- Modules/Client/init.lua
-- Aggregates shared + client-only utilities (client context)

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "Modules/Client/init must be required on the client")

local Modules = script.Parent.Parent
local Shared = require(Modules.Shared.init)

-- Shallow copy shared exports
local M = {}
for k, v in pairs(Shared) do M[k] = v end

-- Client-only modules live in this Client folder
M.CameraUtil = require(script.Parent.CameraUtil)
M.NotificationUtil = require(script.Parent.NotificationUtil)
M.NotificationQueue = require(script.Parent.NotificationQueue)
M.ModalUtil = require(script.Parent.ModalUtil)
M.ClientRateLimiter = require(script.Parent.ClientRateLimiter)
M.ProgressBar = require(script.Parent.ProgressBar)

return M
