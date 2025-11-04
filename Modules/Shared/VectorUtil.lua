-- Modules/Shared/VectorUtil.lua
-- Handy helpers for Vector2/Vector3 math

local VectorUtil = {}

function VectorUtil.clampMagnitude(v: Vector3, max: number): Vector3
	local m = v.Magnitude
	if m <= max or m == 0 then return v end
	return v.Unit * max
end

function VectorUtil.horizontal(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

function VectorUtil.distance(a: Vector3, b: Vector3): number
	return (a - b).Magnitude
end

function VectorUtil.distanceXZ(a: Vector3, b: Vector3): number
	local d = Vector3.new(a.X - b.X, 0, a.Z - b.Z)
	return d.Magnitude
end

function VectorUtil.project(a: Vector3, onto: Vector3): Vector3
	if onto.Magnitude == 0 then return Vector3.zero end
	return onto.Unit * a:Dot(onto) / onto.Magnitude
end

function VectorUtil.reject(a: Vector3, onto: Vector3): Vector3
	return a - VectorUtil.project(a, onto)
end

function VectorUtil.angleBetween(a: Vector3, b: Vector3): number
	local ma, mb = a.Magnitude, b.Magnitude
	if ma == 0 or mb == 0 then return 0 end
	local cos = math.clamp(a:Dot(b) / (ma * mb), -1, 1)
	return math.acos(cos)
end

function VectorUtil.fromYawPitch(yaw: number, pitch: number): Vector3
	local cy, sy = math.cos(yaw), math.sin(yaw)
	local cp, sp = math.cos(pitch), math.sin(pitch)
	return Vector3.new(cy * cp, sp, sy * cp)
end

function VectorUtil.approximately(a: Vector3, b: Vector3, eps: number?): boolean
	eps = eps or 1e-4
	return (a - b).Magnitude <= eps
end

function VectorUtil.lerp(a: Vector3, b: Vector3, t: number): Vector3
	return a + (b - a) * t
end

return VectorUtil
