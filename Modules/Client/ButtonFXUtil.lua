-- Modules/Client/ButtonFXUtil.lua
-- Simple hover/press effects for TextButton/ImageButton using UIScale and tweens

local TweenService = game:GetService("TweenService")

local ButtonFXUtil = {}

local DEFAULTS = {
	hoverScale = 1.05,
	pressScale = 0.98,
	tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

local function ensureScale(gui)
	local scale = gui:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = gui
	end
	return scale
end

-- Bind FX to a button; returns unbind()
function ButtonFXUtil.bind(button: GuiObject, options)
	assert(button and button:IsA("GuiObject"), "ButtonFXUtil.bind requires a GuiObject (TextButton/ImageButton)")
	options = options or {}
	local hoverScale = options.hoverScale or DEFAULTS.hoverScale
	local pressScale = options.pressScale or DEFAULTS.pressScale
	local tweenInfo = options.tweenInfo or DEFAULTS.tweenInfo
	local scale = ensureScale(button)

	local hovering = false
	local pressing = false
	local conns = {}

	local function tweenTo(value)
		TweenService:Create(scale, tweenInfo, { Scale = value }):Play()
	end

	conns[#conns+1] = button.MouseEnter:Connect(function()
		hovering = true
		if not pressing then tweenTo(hoverScale) end
	end)
	conns[#conns+1] = button.MouseLeave:Connect(function()
		hovering = false
		pressing = false
		tweenTo(1)
	end)
	if button:IsA("TextButton") or button:IsA("ImageButton") then
		conns[#conns+1] = button.MouseButton1Down:Connect(function()
			pressing = true
			tweenTo(pressScale)
		end)
		conns[#conns+1] = button.MouseButton1Up:Connect(function()
			pressing = false
			if hovering then tweenTo(hoverScale) else tweenTo(1) end
		end)
	end

	return function()
		for _, c in ipairs(conns) do c:Disconnect() end
	end
end

return ButtonFXUtil
