-- Modules/Client/ScreenResizeUtil.lua
-- Emits a signal when the viewport size changes and exposes current viewport size

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Shared = require(script.Parent.Parent.Shared.init)
local Signal = Shared.Signal

local ScreenResizeUtil = {}

local _started = false
local _signal = Signal.new()

local function getCamera()
	return workspace.CurrentCamera
end

local function hook()
	if _started then return end
	_started = true
	local cam = getCamera()
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			_signal:Fire(cam.ViewportSize)
		end)
	end
	UserInputService.WindowSizeChanged:Connect(function(newSize)
		_signal:Fire(Vector2.new(newSize.X, newSize.Y))
	end)
end

-- Connect a handler to viewport size changes; returns RBXScriptConnection-like
function ScreenResizeUtil.onResize(handler)
	hook()
	return _signal:Connect(handler)
end

function ScreenResizeUtil.getViewportSize()
	local cam = getCamera()
	if cam then return cam.ViewportSize end
	return UserInputService:GetScreenSize()
end

return ScreenResizeUtil
