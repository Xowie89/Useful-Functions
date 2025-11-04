-- Modules/Client/ScreenShakeUtil.lua
-- Lightweight camera screen shake with amplitude/frequency and optional decay

local RunService = game:GetService("RunService")

local ScreenShakeUtil = {}

-- Start a camera shake.
-- params: { amplitude = number (studs), frequency = number (hz), duration = number (s), decay = boolean }
-- returns: stop() function
function ScreenShakeUtil.start(params)
	params = params or {}
	local amplitude = params.amplitude or 0.5
	local frequency = params.frequency or 10
	local duration = params.duration or 0.5
	local decay = (params.decay ~= false)

	local cam = workspace.CurrentCamera
	if not cam then return function() end end

	local startTime = time()
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		local t = time() - startTime
		if t >= duration then
			if conn then conn:Disconnect() end
			return
		end

		local progress = math.clamp(t / duration, 0, 1)
		local a = decay and (amplitude * (1 - progress)) or amplitude
		local offset = Vector3.new(
			(math.noise(t * frequency, 0, 0) - 0.5) * 2 * a,
			(math.noise(0, t * frequency, 0) - 0.5) * 2 * a,
			0
		)
		local rot = (math.noise(0, 0, t * frequency) - 0.5) * 2 * (a * 0.1)
		cam.CFrame = cam.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, rot)
	end)

	return function()
		if conn then conn:Disconnect() end
	end
end

return ScreenShakeUtil
