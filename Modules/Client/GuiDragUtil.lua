-- GuiDragUtil.lua
-- Make frames draggable with optional bounds

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
assert(RunService:IsClient(), "GuiDragUtil must be required on the client")

local M = {}

-- attach(frame, opts?) -> detach()
-- opts = { dragHandle = GuiObject?, clampToParent = boolean? }
function M.attach(frame, opts)
	assert(frame and frame:IsA("GuiObject"), "attach: frame GuiObject required")
	opts = opts or {}
	local handle = opts.dragHandle or frame
	local dragging = false
	local startPos, startInputPos
	local movedConn, endedConn

	local function onInputBegan(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = frame.Position
			startInputPos = input.Position
			movedConn = UserInputService.InputChanged:Connect(function(changed)
				if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch then
					local delta = changed.Position - startInputPos
					local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
					if opts.clampToParent and frame.Parent and frame.Parent:IsA("GuiObject") then
						local parent = frame.Parent
						local x = math.clamp(newPos.X.Offset, 0, parent.AbsoluteSize.X - frame.AbsoluteSize.X)
						local y = math.clamp(newPos.Y.Offset, 0, parent.AbsoluteSize.Y - frame.AbsoluteSize.Y)
						newPos = UDim2.new(0, x, 0, y)
					end
					frame.Position = newPos
				end
			end)
			endedConn = UserInputService.InputEnded:Connect(function(ended)
				if ended.UserInputType == input.UserInputType then
					dragging = false
					if movedConn then movedConn:Disconnect() end
					if endedConn then endedConn:Disconnect() end
				end
			end)
		end
	end

	handle.InputBegan:Connect(onInputBegan)

	return function()
		if movedConn then movedConn:Disconnect() end
		if endedConn then endedConn:Disconnect() end
	end
end

return M
