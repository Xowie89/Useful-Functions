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
M.InputUtil = require(script.Parent.InputUtil)
M.DeviceUtil = require(script.Parent.DeviceUtil)
M.ScreenFadeUtil = require(script.Parent.ScreenFadeUtil)
M.GuiDragUtil = require(script.Parent.GuiDragUtil)
M.ViewportUtil = require(script.Parent.ViewportUtil)
M.CursorUtil = require(script.Parent.CursorUtil)
M.ScreenShakeUtil = require(script.Parent.ScreenShakeUtil)
M.HighlightUtil = require(script.Parent.HighlightUtil)
M.TooltipUtil = require(script.Parent.TooltipUtil)
M.HapticUtil = require(script.Parent.HapticUtil)
M.ScreenResizeUtil = require(script.Parent.ScreenResizeUtil)
M.CursorRayUtil = require(script.Parent.CursorRayUtil)
M.ButtonFXUtil = require(script.Parent.ButtonFXUtil)
M.LayoutUtil = require(script.Parent.LayoutUtil)
M.KeybindHintUtil = require(script.Parent.KeybindHintUtil)
M.TouchGestureUtil = require(script.Parent.TouchGestureUtil)
M.OffscreenIndicatorUtil = require(script.Parent.OffscreenIndicatorUtil)
M.ScrollUtil = require(script.Parent.ScrollUtil)
M.SliderUtil = require(script.Parent.SliderUtil)

return M
