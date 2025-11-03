-- ModalUtil.lua
-- Client-side modal prompts/confirmations using PromiseUtil
-- API (client):
--   ModalUtil.confirm(opts) -> Promise<boolean|"Yes"|"No"|string>
-- opts: { title:string?, message:string, buttons:{string}? (default {"OK"}), theme?, size?, corner?, zIndex? }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.PromiseUtil)

local ModalUtil = {}

local function getPlayerGui(): PlayerGui
	local p = Players.LocalPlayer
	if not p then error("ModalUtil must be used from a LocalScript") end
	local pg = p:FindFirstChildOfClass("PlayerGui")
	if not pg then
		p.ChildAdded:Wait()
		pg = p:FindFirstChildOfClass("PlayerGui")
	end
	return pg
end

local function tween(o, info, props)
	local t = TweenService:Create(o, info, props)
	t:Play()
	return t
end

function ModalUtil.confirm(opts)
	assert(RunService:IsClient(), "ModalUtil.confirm must be called on the client")
	opts = opts or {}
	local theme = opts.theme or { bg = Color3.fromRGB(25,25,25), text = Color3.new(1,1,1), accent = Color3.fromRGB(0,170,255) }
	local size = opts.size or UDim2.fromOffset(420, 220)
	local corner = opts.corner or 8
	local z = opts.zIndex or 10
	local title = opts.title or ""
	local message = assert(opts.message, "message is required")
	local buttons = opts.buttons or { "OK" }

	return Promise.new(function(resolve)
		local pg = getPlayerGui()

		local screen = Instance.new("ScreenGui")
		screen.Name = "Modal"
		screen.ResetOnSpawn = false
		screen.IgnoreGuiInset = true
		screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screen.DisplayOrder = z
		screen.Parent = pg

		local overlay = Instance.new("Frame")
		overlay.BackgroundColor3 = Color3.new(0,0,0)
		overlay.BackgroundTransparency = 1
		overlay.Size = UDim2.fromScale(1, 1)
		overlay.Parent = screen

		local window = Instance.new("Frame")
		window.AnchorPoint = Vector2.new(0.5, 0.5)
		window.Position = UDim2.fromScale(0.5, 0.5)
		window.Size = size
		window.BackgroundColor3 = theme.bg
		window.BackgroundTransparency = 1
		window.Parent = screen

		local cornerUI = Instance.new("UICorner")
		cornerUI.CornerRadius = UDim.new(0, corner)
		cornerUI.Parent = window

		local titleLabel
		if title ~= "" then
			titleLabel = Instance.new("TextLabel")
			titleLabel.BackgroundTransparency = 1
			titleLabel.Size = UDim2.new(1, -24, 0, 32)
			titleLabel.Position = UDim2.new(0, 12, 0, 12)
			titleLabel.Font = Enum.Font.GothamBold
			titleLabel.TextColor3 = theme.text
			titleLabel.TextScaled = true
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Text = title
			titleLabel.Parent = window
		end

		local messageLabel = Instance.new("TextLabel")
		messageLabel.BackgroundTransparency = 1
		messageLabel.Size = UDim2.new(1, -24, 0, 100)
		messageLabel.Position = UDim2.new(0, 12, 0, title ~= "" and 52 or 20)
		messageLabel.Font = Enum.Font.Gotham
		messageLabel.TextColor3 = theme.text
		messageLabel.TextWrapped = true
		messageLabel.TextScaled = true
		messageLabel.TextXAlignment = Enum.TextXAlignment.Left
		messageLabel.TextYAlignment = Enum.TextYAlignment.Top
		messageLabel.Text = message
		messageLabel.Parent = window

		local buttonFrame = Instance.new("Frame")
		buttonFrame.BackgroundTransparency = 1
		buttonFrame.Size = UDim2.new(1, -24, 0, 40)
		buttonFrame.Position = UDim2.new(0, 12, 1, -52)
		buttonFrame.Parent = window

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.Padding = UDim.new(0, 8)
		layout.Parent = buttonFrame

		local function makeButton(text)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.fromOffset(110, 40)
			btn.Text = text
			btn.BackgroundColor3 = theme.accent
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Font = Enum.Font.GothamMedium
			btn.TextScaled = true
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, corner)
			c.Parent = btn
			btn.Parent = buttonFrame
			return btn
		end

		for _, label in ipairs(buttons) do
			local btn = makeButton(label)
			btn.MouseButton1Click:Connect(function()
				resolve(label)
			end)
		end

		-- fade in overlay + window
		tween(overlay, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 })
		tween(window, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

		-- resolve cleanup
		local function cleanup()
			tween(window, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
			tween(overlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
			task.delay(0.2, function()
				screen:Destroy()
			end)
		end

		-- Pipe the final resolution through a one-shot promise
		local done = false
		Promise.resolve():andThen(function()
			-- wait for resolve via button clicks
		end):finally(function()
			if not done then return end
			cleanup()
		end)

		-- Wrap resolve to ensure cleanup
		local oldResolve = resolve
		resolve = function(value)
			done = true
			oldResolve(value)
			cleanup()
		end
	end)
end

return ModalUtil