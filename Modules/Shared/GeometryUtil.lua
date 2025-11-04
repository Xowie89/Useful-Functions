-- Modules/Shared/GeometryUtil.lua
-- Common 3D geometry helpers (pure math, no services)

local GeometryUtil = {}

-- Compute axis-aligned bounding box from a sequence of Vector3 points
-- returns min:Vector3, max:Vector3
function GeometryUtil.aabbFromPoints(points)
	local minV = Vector3.new(math.huge, math.huge, math.huge)
	local maxV = Vector3.new(-math.huge, -math.huge, -math.huge)
	for _, p in ipairs(points) do
		minV = Vector3.new(math.min(minV.X, p.X), math.min(minV.Y, p.Y), math.min(minV.Z, p.Z))
		maxV = Vector3.new(math.max(maxV.X, p.X), math.max(maxV.Y, p.Y), math.max(maxV.Z, p.Z))
	end
	return minV, maxV
end

-- Convert AABB min/max to center CFrame and size Vector3
function GeometryUtil.aabbToCFrameSize(minV: Vector3, maxV: Vector3)
	local size = maxV - minV
	local center = (minV + maxV) * 0.5
	return CFrame.new(center), size
end

-- Compute AABB from a list of parts or a Model (uses part bounding boxes, not rotated fit)
function GeometryUtil.aabbFromInstance(inst)
	local points = {}
	local function add(a, b)
		points[#points+1] = a
		points[#points+1] = b
	end
	local function accumulate(part)
		local cf, size = part.CFrame, part.Size
		local hx, hy, hz = size.X*0.5, size.Y*0.5, size.Z*0.5
		local corners = {
			Vector3.new(-hx,-hy,-hz), Vector3.new(-hx,-hy, hz), Vector3.new(-hx, hy,-hz), Vector3.new(-hx, hy, hz),
			Vector3.new( hx,-hy,-hz), Vector3.new( hx,-hy, hz), Vector3.new( hx, hy,-hz), Vector3.new( hx, hy, hz),
		}
		for _, c in ipairs(corners) do
			local world = cf:PointToWorldSpace(c)
			points[#points+1] = world
		end
	end
	if inst:IsA("Model") then
		for _, d in ipairs(inst:GetDescendants()) do
			if d:IsA("BasePart") then accumulate(d) end
		end
	elseif inst:IsA("BasePart") then
		accumulate(inst)
	end
	if #points == 0 then return nil end
	local minV, maxV = GeometryUtil.aabbFromPoints(points)
	return minV, maxV
end

-- Ray-plane intersection: returns point or nil if parallel or behind ray
-- plane defined by a point and a normal
function GeometryUtil.rayPlaneIntersection(rayOrigin: Vector3, rayDir: Vector3, planePoint: Vector3, planeNormal: Vector3)
	rayDir = rayDir.Unit
	local denom = planeNormal:Dot(rayDir)
	if math.abs(denom) < 1e-6 then return nil end
	local t = (planePoint - rayOrigin):Dot(planeNormal) / denom
	if t < 0 then return nil end
	return rayOrigin + rayDir * t
end

-- Closest point on the line segment AB to point P
function GeometryUtil.closestPointOnSegment(a: Vector3, b: Vector3, p: Vector3)
	local ab = b - a
	local t = (p - a):Dot(ab) / math.max(ab:Dot(ab), 1e-9)
	t = math.clamp(t, 0, 1)
	return a + ab * t, t
end

-- 2D point in triangle test using barycentric technique (x,y from Vector2)
function GeometryUtil.pointInTriangle2D(p: Vector2, a: Vector2, b: Vector2, c: Vector2)
	local v0 = c - a
	local v1 = b - a
	local v2 = p - a
	local dot00 = v0:Dot(v0)
	local dot01 = v0:Dot(v1)
	local dot02 = v0:Dot(v2)
	local dot11 = v1:Dot(v1)
	local dot12 = v1:Dot(v2)
	local invDenom = 1 / math.max(dot00 * dot11 - dot01 * dot01, 1e-12)
	local u = (dot11 * dot02 - dot01 * dot12) * invDenom
	local v = (dot00 * dot12 - dot01 * dot02) * invDenom
	return (u >= 0) and (v >= 0) and (u + v <= 1)
end

return GeometryUtil
