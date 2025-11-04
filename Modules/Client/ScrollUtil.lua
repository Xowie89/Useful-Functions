-- Modules/Client/ScrollUtil.lua
-- Smooth scrolling helpers for ScrollingFrame

local TweenService = game:GetService("TweenService")

local ScrollUtil = {}

-- Smoothly scroll to CanvasPosition target (Vector2) with tween info
function ScrollUtil.smoothScrollTo(scroller: ScrollingFrame, target: Vector2, tweenInfo: TweenInfo?)
	assert(scroller and scroller:IsA("ScrollingFrame"), "ScrollUtil.smoothScrollTo requires a ScrollingFrame")
	tweenInfo = tweenInfo or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local proxy = Instance.new("Vector3Value")
	proxy.Value = Vector3.new(scroller.CanvasPosition.X, scroller.CanvasPosition.Y, 0)
	local t = TweenService:Create(proxy, tweenInfo, { Value = Vector3.new(target.X, target.Y, 0) })
	local conn
	conn = proxy.Changed:Connect(function()
		local v = proxy.Value
		scroller.CanvasPosition = Vector2.new(v.X, v.Y)
	end)
	t.Completed:Connect(function()
		conn:Disconnect()
		proxy:Destroy()
	end)
	t:Play()
	return t
end

-- Scroll by an offset (dx, dy) relative to current CanvasPosition
function ScrollUtil.scrollBy(scroller: ScrollingFrame, dx: number, dy: number, tweenInfo: TweenInfo?)
	local cur = scroller.CanvasPosition
	return ScrollUtil.smoothScrollTo(scroller, Vector2.new(cur.X + (dx or 0), cur.Y + (dy or 0)), tweenInfo)
end

return ScrollUtil
