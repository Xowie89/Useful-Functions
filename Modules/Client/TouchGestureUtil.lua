-- Modules/Client/TouchGestureUtil.lua
-- Recognize pan, pinch (scale), and rotate gestures from multi-touch input

local UserInputService = game:GetService("UserInputService")

-- Simple signal using BindableEvent
local function createSignal()
	local ev = Instance.new("BindableEvent")
	return {
		Connect = function(_, fn) return ev.Event:Connect(fn) end,
		Fire = function(_, ...) ev:Fire(...) end,
	}
end

local TouchGestureUtil = {}

-- Binds gesture recognition; returns controller with signals and a destroy() method.
-- options: { minPinchDelta = number, minRotateDelta = number (radians), minPanDelta = number (studs-ish screen pixels) }
function TouchGestureUtil.bind(options)
	options = options or {}
	local minPinch = options.minPinchDelta or 4 -- pixels delta in distance
	local minRotate = options.minRotateDelta or math.rad(2)
	local minPan = options.minPanDelta or 3

	local touches = {}
	local lastCenter
	local lastDistance
	local lastAngle

	local api = {
		OnPan = createSignal(),
		OnPinch = createSignal(), -- sign: + zoom in, - zoom out; delta pixels
		OnRotate = createSignal(), -- radians, sign indicates direction
	}

	local addedConn, changedConn, endedConn

	local function getTwo()
		local t = {}
		for _, info in pairs(touches) do
			t[#t+1] = info
		end
		if #t >= 2 then return t[1], t[2] end
		return nil
	end

	local function analyze()
		local a, b = getTwo()
		if not a then return end
		local center = (a.Position + b.Position) / 2
		local diff = b.Position - a.Position
		local dist = diff.Magnitude
		local angle = math.atan2(diff.Y, diff.X)

		if lastCenter then
			local panDelta = (center - lastCenter).Magnitude
			if panDelta >= minPan then
				api.OnPan:Fire(center - lastCenter)
			end
		end
		if lastDistance then
			local pinchDelta = dist - lastDistance
			if math.abs(pinchDelta) >= minPinch then
				api.OnPinch:Fire(pinchDelta)
			end
		end
		if lastAngle then
			local rotDelta = angle - lastAngle
			-- wrap to [-pi, pi]
			rotDelta = (rotDelta + math.pi) % (2*math.pi) - math.pi
			if math.abs(rotDelta) >= minRotate then
				api.OnRotate:Fire(rotDelta)
			end
		end

		lastCenter = center
		lastDistance = dist
		lastAngle = angle
	end

	addedConn = UserInputService.TouchStarted:Connect(function(input)
		touches[input] = input
		analyze()
	end)
	changedConn = UserInputService.TouchMoved:Connect(function(input)
		if touches[input] then
			touches[input] = input
			analyze()
		end
	end)
	endedConn = UserInputService.TouchEnded:Connect(function(input)
		touches[input] = nil
		-- reset state when fewer than 2 fingers
		local count = 0
		for _ in pairs(touches) do count += 1 end
		if count < 2 then
			lastCenter, lastDistance, lastAngle = nil, nil, nil
		end
	end)

	function api:Destroy()
		if addedConn then addedConn:Disconnect() end
		if changedConn then changedConn:Disconnect() end
		if endedConn then endedConn:Disconnect() end
		self.OnPan = nil
		self.OnPinch = nil
		self.OnRotate = nil
	end

	return api
end

return TouchGestureUtil
