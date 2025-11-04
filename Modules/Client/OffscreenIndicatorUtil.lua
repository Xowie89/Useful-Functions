-- Modules/Client/OffscreenIndicatorUtil.lua
-- Display a simple arrow indicator pointing toward a world target when it is off-screen

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function getCamera()
	return workspace.CurrentCamera
end

local function makeArrow()
	local img = Instance.new("ImageLabel")
	img.Name = "OffscreenArrow"
	img.BackgroundTransparency = 1
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Size = UDim2.fromOffset(24, 24)
	img.Image = "rbxassetid://1095708" -- simple triangle icon; replace with your asset
	img.ImageColor3 = Color3.fromRGB(255, 255, 255)
	img.Visible = false
	return img
end

local OffscreenIndicatorUtil = {}

-- Attach an off-screen arrow indicator for a BasePart/Model primary part
-- options: { color: Color3, margin: number (pixels), parent: PlayerGui | ScreenGui }
-- returns: stop() to cleanup
function OffscreenIndicatorUtil.attach(target: Instance, options)
	options = options or {}
	local cam = getCamera()
	if not cam then return function() end end

	local player = Players.LocalPlayer
	if not player then return function() end end
	local pg = player:FindFirstChildOfClass("PlayerGui")
	if not pg then return function() end end

	local screenGui
	if options.parent and options.parent:IsA("ScreenGui") then
		screenGui = options.parent
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "_OffscreenIndicators"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 5000
		screenGui.Parent = pg
	end

	local arrow = makeArrow()
	if options.color then arrow.ImageColor3 = options.color end
	arrow.Parent = screenGui
	local margin = options.margin or 24

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not target or not target.Parent then
			arrow.Visible = false
			return
		end
		-- target world position
		local pos = target:IsA("Model") and (target.PrimaryPart and target.PrimaryPart.Position) or target.Position
		if not pos then
			arrow.Visible = false
			return
		end
		local vp, onScreen = cam:WorldToViewportPoint(pos)
		local viewportSize = cam.ViewportSize
		if onScreen and vp.Z > 0 and vp.X >= 0 and vp.X <= viewportSize.X and vp.Y >= 0 and vp.Y <= viewportSize.Y then
			arrow.Visible = false
			return
		end

		-- Compute angle toward target
		local dir = (pos - cam.CFrame.Position).Unit
		local right = cam.CFrame.RightVector
		local up = cam.CFrame.UpVector
		local forward = cam.CFrame.LookVector
		local x = dir:Dot(right)
		local y = dir:Dot(up)
		local z = dir:Dot(forward)
		local angle = math.atan2(y, x) -- orientation around screen center

		-- Place arrow on screen edge
		local center = viewportSize / 2
		local r = math.min(center.X, center.Y) - margin
		local p = Vector2.new(center.X + r * math.cos(angle), center.Y + r * math.sin(angle))
		arrow.Position = UDim2.fromOffset(p.X, p.Y)
		arrow.Rotation = math.deg(angle) + 90
		arrow.Visible = true
	end)

	return function()
		if conn then conn:Disconnect() end
		if arrow then arrow:Destroy() end
		if screenGui and options.parent ~= screenGui then
			screenGui:Destroy()
		end
	end
end

return OffscreenIndicatorUtil
