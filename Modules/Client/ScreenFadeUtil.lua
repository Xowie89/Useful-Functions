-- ScreenFadeUtil.lua
-- Simple screen fade in/out overlay

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
assert(RunService:IsClient(), "ScreenFadeUtil must be required on the client")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function ensureOverlay()
	local gui = PlayerGui:FindFirstChild("__UF_FadeGui")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "__UF_FadeGui"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.Parent = PlayerGui
		local frame = Instance.new("Frame")
		frame.Name = "Overlay"
		frame.BackgroundColor3 = Color3.new(0,0,0)
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1,1)
		frame.Parent = gui
	end
	return gui:FindFirstChild("Overlay")
end

local function tweenTransparency(frame, target, duration)
	duration = duration or 0.5
	local tween = game:GetService("TweenService"):Create(frame, TweenInfo.new(duration), { BackgroundTransparency = target })
	tween:Play()
	tween.Completed:Wait()
end

local M = {}

function M.fadeIn(duration)
	local overlay = ensureOverlay()
	tweenTransparency(overlay, 0, duration)
end

function M.fadeOut(duration)
	local overlay = ensureOverlay()
	tweenTransparency(overlay, 1, duration)
end

function M.flash(duration)
	M.fadeIn((duration or 0.5)/2)
	M.fadeOut((duration or 0.5)/2)
end

return M
