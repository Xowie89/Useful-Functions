-- Modules/Client/KeybindHintUtil.lua
-- On-screen keybind hints bar (bottom center) with simple API

local Players = game:GetService("Players")

local KeybindHintUtil = {}

local function getContainer()
	local player = Players.LocalPlayer
	if not player then return end
	local gui = player:FindFirstChildOfClass("PlayerGui")
	if not gui then return end
	local screen = gui:FindFirstChild("_KeybindHints")
	if not screen then
		screen = Instance.new("ScreenGui")
		screen.ResetOnSpawn = false
		screen.Name = "_KeybindHints"
		screen.DisplayOrder = 9999
		screen.Parent = gui

		local frame = Instance.new("Frame")
		frame.Name = "Bar"
		frame.AnchorPoint = Vector2.new(0.5, 1)
		frame.Position = UDim2.fromScale(0.5, 1)
		frame.Size = UDim2.fromOffset(100, 32)
		frame.BackgroundTransparency = 1
		frame.Parent = screen

		local list = Instance.new("UIListLayout")
		list.FillDirection = Enum.FillDirection.Horizontal
		list.HorizontalAlignment = Enum.HorizontalAlignment.Center
		list.VerticalAlignment = Enum.VerticalAlignment.Center
		list.Padding = UDim.new(0, 8)
		list.Parent = frame
	end
	return screen, screen:FindFirstChild("Bar")
end

local _id = 0

local function makeTag(text)
	local tag = Instance.new("TextLabel")
	tag.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	tag.BorderSizePixel = 0
	tag.TextColor3 = Color3.new(1,1,1)
	tag.Font = Enum.Font.GothamSemibold
	tag.TextSize = 14
	tag.AutoLocalize = false
	tag.AutomaticSize = Enum.AutomaticSize.XY
	tag.Size = UDim2.fromOffset(20, 20)
	tag.Text = text
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.Parent = tag
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = tag
	return tag
end

-- Show a keybind hint; returns id
-- options: { key: string, text: string }
function KeybindHintUtil.show(options)
	options = options or {}
	local key = options.key or "E"
	local text = options.text or "Interact"
	local screen, bar = getContainer()
	if not (screen and bar) then return nil end
	_id += 1
	local group = Instance.new("Frame")
	group.Name = "Hint" .. _id
	group.BackgroundTransparency = 1
	group.Size = UDim2.new(0, 0, 0, 0)
	group.Parent = bar

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 6)
	list.Parent = group

	local keyTag = makeTag(key)
	keyTag.Parent = group
	local textTag = makeTag(text)
	textTag.BackgroundColor3 = Color3.fromRGB(55,55,60)
	textTag.Parent = group

	return _id
end

-- Remove a previously shown hint by id
function KeybindHintUtil.remove(id)
	local _, bar = getContainer()
	if not bar then return end
	local child = bar:FindFirstChild("Hint" .. tostring(id))
	if child then child:Destroy() end
end

return KeybindHintUtil
