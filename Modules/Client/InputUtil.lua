-- InputUtil.lua
-- Lightweight wrappers for ContextActionService and common input patterns

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "InputUtil must be required on the client")

local M = {}

-- bindAction(name, callback, touchEnabled?, keysOrTypes?)
-- callback(actionName, inputState, inputObject) -> Enum.ContextActionResult
function M.bindAction(name, callback, touchEnabled, keys)
	ContextActionService:BindAction(name, callback, touchEnabled ~= false, table.unpack(keys or {}))
	return function()
		ContextActionService:UnbindAction(name)
	end
end

function M.bindOnce(name, callback, touchEnabled, keys)
	local unbind
	unbind = M.bindAction(name, function(actionName, state, input)
		if state == Enum.UserInputState.Begin then
			local res = callback(actionName, state, input)
			if unbind then unbind() end
			return res
		end
	end, touchEnabled, keys)
	return unbind
end

-- Utility: onKey(keyCode, fn) listen for a single Begin event
function M.onKey(keyCode, fn)
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == keyCode then
			fn(input)
			if conn then conn:Disconnect() end
		end
	end)
	return conn
end

-- Utility: current input mode hints
function M.isTouch()
	return UserInputService.TouchEnabled
end
function M.isGamepad()
	return UserInputService.GamepadEnabled
end
function M.isKeyboardMouse()
	return UserInputService.KeyboardEnabled or UserInputService.MouseEnabled
end

return M
