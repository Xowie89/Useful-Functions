-- ProgressBar.lua
-- Client-side simple progress bar GUI component
-- API (client):
--   local bar = ProgressBar.create(parentOrPlayerGui?, opts?)
--   bar:SetProgress(alpha:number, tweenSeconds?:number)
--   bar:SetText(text:string?)
--   bar:Show()
--   bar:Hide()
--   bar:Destroy()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ProgressBar = {}
ProgressBar.__index = ProgressBar

local function getPlayerGui()
	local p = Players.LocalPlayer
	if not p then error("ProgressBar must be used from a LocalScript") end
	local pg = p:FindFirstChildOfClass("PlayerGui")
	if not pg then
		p.ChildAdded:Wait()
		pg = p:FindFirstChildOfClass("PlayerGui")
	end
	return pg
end

function ProgressBar.create(parent: Instance?, opts: { size: UDim2?, position: UDim2?, corner: number?, theme: {bg:Color3, fill:Color3, text:Color3}? }?)
	assert(RunService:IsClient(), "ProgressBar must be created on the client")
	opts = opts or {}
	local size = opts.size or UDim2.fromOffset(400, 24)
	local position = opts.position or UDim2.new(0.5, 0, 0.85, 0)
	local corner = opts.corner or 8
	local theme = opts.theme or { bg = Color3.fromRGB(30,30,30), fill = Color3.fromRGB(0,170,255), text = Color3.new(1,1,1) }

	local pg = parent or getPlayerGui()
	local gui
	if pg:IsA("ScreenGui") then
		gui = pg
	else
		gui = Instance.new("ScreenGui")
		gui.Name = "ProgressBarGui"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.Parent = pg
	end

	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = theme.bg
	frame.BackgroundTransparency = 0.2
	frame.Parent = gui

	local cornerUI = Instance.new("UICorner")
	cornerUI.CornerRadius = UDim.new(0, corner)
	cornerUI.Parent = frame

	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = theme.fill
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, corner)
	barCorner.Parent = bar

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.TextColor3 = theme.text
	label.Text = ""
	label.Font = Enum.Font.Gotham
	label.TextScaled = true
	label.Parent = frame

	local self = setmetatable({ _gui = gui, _frame = frame, _bar = bar, _label = label, _tween = nil }, ProgressBar)
	return self
end

function ProgressBar:SetProgress(alpha: number, tweenSeconds: number?)
	alpha = math.clamp(alpha or 0, 0, 1)
	if self._tween then self._tween:Cancel() end
	local goal = { Size = UDim2.new(alpha, 0, 1, 0) }
	if tweenSeconds and tweenSeconds > 0 then
		self._tween = TweenService:Create(self._bar, TweenInfo.new(tweenSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
		self._tween:Play()
	else
		self._bar.Size = goal.Size
	end
end

function ProgressBar:SetText(text: string?)
	self._label.Text = text or ""
end

function ProgressBar:Show()
	self._frame.Visible = true
end

function ProgressBar:Hide()
	self._frame.Visible = false
end

function ProgressBar:Destroy()
	if self._tween then self._tween:Cancel() end
	self._frame:Destroy()
end

return ProgressBar