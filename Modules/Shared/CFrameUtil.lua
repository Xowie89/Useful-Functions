-- CFrameUtil.lua
-- Helpers to work with CFrame and rotations
-- API:
--   lookAt(origin: Vector3, target: Vector3, up?: Vector3) -> CFrame
--   fromYawPitchRoll(y, p, r) -> CFrame, toYawPitchRoll(cf) -> (y, p, r)
--   rotateAround(cf, origin, axisUnit: Vector3, radians: number) -> CFrame
--   offset(cf, delta: Vector3) -> CFrame
--   clampYaw(cf, minYaw: number, maxYaw: number) -> CFrame

local CFrameUtil = {}

function CFrameUtil.lookAt(origin: Vector3, target: Vector3, up: Vector3?): CFrame
	up = up or Vector3.new(0, 1, 0)
	return CFrame.lookAt(origin, target, up)
end

function CFrameUtil.fromYawPitchRoll(y: number, p: number, r: number): CFrame
	return CFrame.Angles(0, y, 0) * CFrame.Angles(p, 0, 0) * CFrame.Angles(0, 0, r)
end

function CFrameUtil.toYawPitchRoll(cf: CFrame): (number, number, number)
	local x, y, z = cf:ToOrientation()
	-- ToOrientation returns (x=rx, y=ry, z=rz) which correspond to pitch, yaw, roll
	return y, x, z
end

function CFrameUtil.rotateAround(cf: CFrame, origin: Vector3, axisUnit: Vector3, radians: number): CFrame
	local toOrigin = cf.Position - origin
	local rot = CFrame.fromAxisAngle(axisUnit.Unit, radians)
	local newPos = origin + (rot:VectorToWorldSpace(toOrigin))
	local y, p, r = CFrameUtil.toYawPitchRoll(cf)
	local newRot = rot * CFrameUtil.fromYawPitchRoll(y, p, r)
	return CFrame.new(newPos) * newRot
end

function CFrameUtil.offset(cf: CFrame, delta: Vector3): CFrame
	return cf + delta
end

function CFrameUtil.clampYaw(cf: CFrame, minYaw: number, maxYaw: number): CFrame
	local y, p, r = CFrameUtil.toYawPitchRoll(cf)
	y = math.clamp(y, minYaw, maxYaw)
	local pos = cf.Position
	return CFrame.new(pos) * CFrameUtil.fromYawPitchRoll(y, p, r)
end

return CFrameUtil