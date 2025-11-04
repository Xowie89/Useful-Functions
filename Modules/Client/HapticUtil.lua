-- Modules/Client/HapticUtil.lua
-- Wrapper around HapticService for controller vibration (where supported)

local HapticService = game:GetService("HapticService")

local HapticUtil = {}

-- Returns true if the motor is supported on the given gamepad
local function isSupported(gamepad, motor)
	local ok, supported = pcall(function()
		return HapticService:IsVibrationSupported(gamepad) and HapticService:IsMotorSupported(gamepad, motor)
	end)
	return ok and supported or false
end

-- Vibrate a specific gamepad's Large motor for duration seconds at intensity [0..1]
function HapticUtil.rumble(gamepad, intensity, duration)
	intensity = math.clamp(tonumber(intensity) or 0, 0, 1)
	duration = tonumber(duration) or 0.2
	local motor = Enum.VibrationMotor.Large
	if not isSupported(gamepad, motor) then return false end

	local ok = pcall(function()
		HapticService:SetMotor(gamepad, motor, intensity)
	end)
	if not ok then return false end

	task.delay(duration, function()
		pcall(function()
			HapticService:SetMotor(gamepad, motor, 0)
		end)
	end)
	return true
end

-- Vibrate all connected gamepads at the given intensity for duration seconds
function HapticUtil.rumbleAll(intensity, duration)
	local any = false
	for _, gamepad in ipairs(Enum.UserInputType:GetEnumItems()) do
		if gamepad.Name:find("Gamepad") then
			any = HapticUtil.rumble(gamepad, intensity, duration) or any
		end
	end
	return any
end

return HapticUtil
