-- DeviceUtil.lua
-- Detect platform, viewport, DPI-ish scale factors and input mode

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
assert(RunService:IsClient(), "DeviceUtil must be required on the client")

local M = {}

function M.viewport()
	return Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(0,0)
end

function M.platform()
	-- Provides a coarse classification
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		return "mobile"
	end
	if UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
		return "console"
	end
	return "desktop"
end

function M.isSmallScreen()
	local v = M.viewport()
	return v.X < 900 or v.Y < 600
end

function M.safeAreaInset()
	-- Returns Vector2 offsets for top/bottom notch areas if available
	local topInset = GuiService:GetGuiInset()
	return Vector2.new(topInset.X, topInset.Y)
end

return M
