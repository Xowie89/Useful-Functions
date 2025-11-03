-- TweenUtil.lua
-- Helpers for creating and awaiting tweens
-- API:
--   TweenUtil.tween(instance, tweenInfo, goalProps) -> Tween
--   TweenUtil.tweenAsync(instance, tweenInfo, goalProps) -> success:boolean
--   TweenUtil.sequence(instance, stepsArray) -> success:boolean
--     step = { info = TweenInfo.new(...), goal = {Prop=Value}, yield = true }

local TweenService = game:GetService("TweenService")

local TweenUtil = {}

function TweenUtil.tween(instance: Instance, tweenInfo: TweenInfo, goalProps: {[string]: any}): Tween
	assert(instance and tweenInfo and goalProps, "tween requires instance, info, goal")
	local tween = TweenService:Create(instance, tweenInfo, goalProps)
	tween:Play()
	return tween
end

function TweenUtil.tweenAsync(instance: Instance, tweenInfo: TweenInfo, goalProps: {[string]: any})
	local tween = TweenUtil.tween(instance, tweenInfo, goalProps)
	local completed = Instance.new("BindableEvent")
	local conn
	conn = tween.Completed:Connect(function()
		if conn then conn:Disconnect() end
		completed:Fire(true)
	end)
	local ok = completed.Event:Wait()
	completed:Destroy()
	return ok == true
end

function TweenUtil.sequence(instance: Instance, steps: { [number]: {info: TweenInfo, goal: {[string]: any}, yield: boolean?} }): boolean
	local lastOk = true
	for _, step in ipairs(steps) do
		local tween = TweenUtil.tween(instance, step.info, step.goal)
		if step.yield ~= false then
			local done = Instance.new("BindableEvent")
			local c
			c = tween.Completed:Connect(function()
				if c then c:Disconnect() end
				done:Fire(true)
			end)
			local ok = done.Event:Wait()
			done:Destroy()
			lastOk = ok == true
		end
	end
	return lastOk
end

return TweenUtil