-- Modules/Client/SliderUtil.lua
-- Minimal horizontal slider factory with value [0..1]

local UserInputService = game:GetService("UserInputService")

local function createSignal()
	local ev = Instance.new("BindableEvent")
	return {
		Connect = function(_, fn) return ev.Event:Connect(fn) end,
		Fire = function(_, ...) ev:Fire(...) end,
	}
end

local SliderUtil = {}

-- Create a slider UI and return { Gui, SetValue, GetValue, OnChanged }
-- options: { width: number, height: number, initial: number, parent: Instance }
function SliderUtil.create(options)
	options = options or {}
	local width = options.width or 200
	local height = options.height or 24
	local value = math.clamp(tonumber(options.initial) or 0, 0, 1)

	local frame = Instance.new("Frame")
	frame.Name = "Slider"
	frame.Size = UDim2.fromOffset(width, height)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	frame.BorderSizePixel = 0
	frame.Active = true

	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.Position = UDim2.fromScale(0, 0.5)
	bar.Size = UDim2.fromOffset(0, height - 8)
	bar.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
	bar.BorderSizePixel = 0
	bar.Parent = frame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame
	local corner2 = Instance.new("UICorner")
	corner2.CornerRadius = UDim.new(0, 6)
	corner2.Parent = bar

	local OnChanged = createSignal()

	local function render()
		bar.Size = UDim2.fromOffset(math.floor(value * width), height - 8)
	end

	local dragging = false
	local function setFromX(x)
		local rel = math.clamp((x - frame.AbsolutePosition.X) / width, 0, 1)
		if math.abs(rel - value) > 1e-3 then
			value = rel
			render()
			OnChanged:Fire(value)
		end
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Name:find("Touch") then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Name:find("Touch")) then
			setFromX(input.Position.X)
		end
	end)
	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Name:find("Touch") then
			dragging = false
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	local api = {
		Gui = frame,
		OnChanged = OnChanged,
		SetValue = function(_, v)
			v = math.clamp(tonumber(v) or 0, 0, 1)
			if math.abs(v - value) > 1e-6 then
				value = v
				render()
				OnChanged:Fire(value)
			end
		end,
		GetValue = function() return value end,
	}

	render()
	if options.parent then frame.Parent = options.parent end
	return api
end

return SliderUtil
