-- Modules/Client/CursorUtil.lua
-- Utilities for cursor visibility, icon, and mouse lock behavior

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local CursorUtil = {}

-- Show the default Roblox cursor
function CursorUtil.show()
	UserInputService.MouseIconEnabled = true
end

-- Hide the cursor
function CursorUtil.hide()
	UserInputService.MouseIconEnabled = false
end

-- Set a custom cursor icon (string URL or rbxasset id). Pass nil to reset.
function CursorUtil.setIcon(icon)
	local player = Players.LocalPlayer
	if not player then return end
	local mouse = player:GetMouse()
	if icon and type(icon) == "string" then
		mouse.Icon = icon
	else
		mouse.Icon = ""
	end
end

-- Lock or unlock the mouse to the center of the screen
function CursorUtil.lockCenter(enable)
	UserInputService.MouseBehavior = enable and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
end

function CursorUtil.isLocked()
	return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

return CursorUtil
