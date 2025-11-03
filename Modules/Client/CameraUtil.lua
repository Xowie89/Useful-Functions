-- CameraUtil.lua
-- Client-side camera helpers: subject, tween to CFrame, simple shake
-- API (client):
--   CameraUtil.setSubject(subject: Instance?) -> ()
--   CameraUtil.tweenTo(cframe: CFrame, info: TweenInfo, focus?: Vector3) -> success:boolean
--   CameraUtil.shake(duration:number, magnitude:number?, frequency:number?) -> handle { Stop }

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local CameraUtil = {}

local function getCamera(): Camera
	local cam = workspace.CurrentCamera
	if not cam then
		workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
		cam = workspace.CurrentCamera
	end
	return cam
end

function CameraUtil.setSubject(subject: Instance?)
	assert(RunService:IsClient(), "CameraUtil.setSubject should be called on the client")
	local cam = getCamera()
	cam.CameraSubject = subject or nil
end

function CameraUtil.tweenTo(cf: CFrame, info: TweenInfo, focus: Vector3?)
	assert(RunService:IsClient(), "CameraUtil.tweenTo should be called on the client")
	local cam = getCamera()
	if focus then
		cam.CFrame = CFrame.new(cf.Position, focus)
	end
	local t = TweenService:Create(cam, info, { CFrame = cf })
	t:Play()
	local done = Instance.new("BindableEvent")
	local c
	c = t.Completed:Connect(function()
		if c then c:Disconnect() end
		done:Fire(true)
	end)
	local ok = done.Event:Wait()
	done:Destroy()
	return ok == true
end

function CameraUtil.shake(duration: number, magnitude: number?, frequency: number?)
	assert(RunService:IsClient(), "CameraUtil.shake should be called on the client")
	duration = duration or 0.5
	magnitude = magnitude or 0.2 -- studs/rotation small
	frequency = frequency or 15
	local cam = getCamera()
	local start = time()
	local base = cam.CFrame
	local running = true
	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		if not running then return end
		local t = time() - start
		if t >= duration then
			running = false
			conn:Disconnect()
			cam.CFrame = base
			return
		end
		-- simple pseudo-random offset
		local n = math.noise(t * frequency, 0, 0)
		local offsetPos = Vector3.new((n - 0.5) * magnitude, (math.noise(0, t * frequency, 0) - 0.5) * magnitude, 0)
		cam.CFrame = base * CFrame.new(offsetPos)
	end)
	return {
		Stop = function()
			running = false
			if conn then conn:Disconnect() end
			cam.CFrame = base
		end
	}
end

return CameraUtil