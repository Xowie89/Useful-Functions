-- Modules/Client/TooltipUtil.lua
-- Simple hover tooltip for GuiObjects

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local TooltipUtil = {}

local function createTooltipGui(text)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "_TooltipUtil"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 10_000

	local label = Instance.new("TextLabel")
	label.Name = "Tooltip"
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.Text = text or ""
	label.AutomaticSize = Enum.AutomaticSize.XY
	label.Size = UDim2.fromOffset(4, 4)
	label.Position = UDim2.fromOffset(0, 0)
	label.Parent = screenGui

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingTop = UDim.new(0, 6)
	padding.PaddingBottom = UDim.new(0, 6)
	padding.Parent = label

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = label

	return screenGui, label
end

-- Bind a tooltip to a GuiObject. Shows on hover and follows the mouse.
-- options: { text: string, offset: Vector2 }
-- returns: unbind() function
function TooltipUtil.bind(guiObject, options)
	assert(guiObject and guiObject:IsA("GuiObject"), "TooltipUtil.bind requires a GuiObject")
	options = options or {}

	local player = Players.LocalPlayer
	local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return function() end end

	local screenGui, label = createTooltipGui(options.text or guiObject.Name)
	screenGui.Parent = playerGui
	local offset = options.offset or Vector2.new(16, 16)

	local function updatePos(pos)
		label.Position = UDim2.fromOffset(pos.X + offset.X, pos.Y + offset.Y)
	end

	local visible = false
	local enterConn, leaveConn, moveConn

	local function show()
		screenGui.Enabled = true
		visible = true
	end
	local function hide()
		screenGui.Enabled = false
		visible = false
	end

	enterConn = guiObject.MouseEnter:Connect(function()
		show()
	end)
	leaveConn = guiObject.MouseLeave:Connect(function()
		hide()
	end)
	moveConn = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and visible then
			local pos = UserInputService:GetMouseLocation()
			updatePos(pos)
		end
	end)

	-- Start hidden
	hide()

	return function()
		if enterConn then enterConn:Disconnect() end
		if leaveConn then leaveConn:Disconnect() end
		if moveConn then moveConn:Disconnect() end
		if screenGui then screenGui:Destroy() end
	end
end

return TooltipUtil
