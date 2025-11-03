-- NotificationUtil.lua
-- Client-side toast/alert notifications with tweens
-- API (client):
--   NotificationUtil.show(text: string, opts?) -> handle { Close:()->(), Destroy:()->() }
-- opts: { duration:number? (default 2.5), parent:Instance? (ScreenGui or PlayerGui), theme:{bg:Color3, fg:Color3}?, position:UDim2?, size:UDim2?, stroke:boolean?, corner:number?, padding:number?, fade:number? }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationUtil = {}

local function getPlayerGui(): PlayerGui
	local player = Players.LocalPlayer
	if not player then error("NotificationUtil.show must be called from a LocalScript") end
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then
		player.ChildAdded:Wait()
		pg = player:FindFirstChildOfClass("PlayerGui")
	end
	return pg
end

local function tween(o, info, props)
	local t = TweenService:Create(o, info, props)
	t:Play()
	return t
end

function NotificationUtil.show(text: string, opts: {
	duration: number?, parent: Instance?, theme: {bg: Color3, fg: Color3}?, position: UDim2?, size: UDim2?, stroke: boolean?, corner: number?, padding: number?, fade: number?
}?)
	assert(RunService:IsClient(), "NotificationUtil.show must be called from the client")
	opts = opts or {}
	local duration = opts.duration or 2.5
	local fade = opts.fade or 0.2
	local theme = opts.theme or { bg = Color3.fromRGB(20,20,20), fg = Color3.new(1,1,1) }
	local size = opts.size or UDim2.fromOffset(380, 48)
	local position = opts.position or UDim2.new(0.5, 0, 0.1, 0)
	local padding = opts.padding or 12
	local corner = opts.corner or 8

	local parent = opts.parent or getPlayerGui()
	local screenGui
	if parent:IsA("ScreenGui") then
		screenGui = parent
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "Notifications"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.Parent = parent
	end

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = theme.bg
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, corner)
	uicorner.Parent = frame

	if opts.stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Transparency = 0.3
		stroke.Color = Color3.new(1,1,1)
		stroke.Parent = frame
	end

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = theme.fg
	label.Size = UDim2.new(1, -padding*2, 1, -padding*2)
	label.Position = UDim2.new(0, padding, 0, padding)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = frame

	-- Fade in
	tween(frame, TweenInfo.new(fade, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.1 })
	tween(label, TweenInfo.new(fade), { TextTransparency = 0 })

	-- Auto close after duration
	local closed = false
	task.delay(duration, function()
		if closed then return end
		closed = true
		tween(frame, TweenInfo.new(fade), { BackgroundTransparency = 1 })
		tween(label, TweenInfo.new(fade), { TextTransparency = 1 })
		task.delay(fade, function()
			frame:Destroy()
		end)
	end)

	return {
		Close = function()
			if closed then return end
			closed = true
			tween(frame, TweenInfo.new(fade), { BackgroundTransparency = 1 })
			tween(label, TweenInfo.new(fade), { TextTransparency = 1 })
			task.delay(fade, function()
				frame:Destroy()
			end)
		end,
		Destroy = function()
			closed = true
			frame:Destroy()
		end,
	}
end

return NotificationUtil