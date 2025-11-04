-- Modules/Client/CursorRayUtil.lua
-- Helpers to get rays and world points from screen/mouse positions

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local function getCamera()
	return workspace.CurrentCamera
end

local CursorRayUtil = {}

-- Returns origin (Vector3) and direction (Vector3) for a given screen point and optional depth (studs)
function CursorRayUtil.screenPointToRay(point: Vector2, depth: number?)
	local cam = getCamera()
	if not cam then return nil end
	local unitRay = cam:ViewportPointToRay(point.X, point.Y)
	local dir = unitRay.Direction
	if depth and typeof(depth) == "number" then
		dir = dir.Unit * depth
	end
	return unitRay.Origin, dir
end

-- Returns origin, direction from the current mouse position
function CursorRayUtil.mouseRay(depth: number?)
	local pos = UserInputService:GetMouseLocation()
	return CursorRayUtil.screenPointToRay(pos, depth)
end

-- Raycast from a screen point using optional RaycastParams; returns RaycastResult or nil
function CursorRayUtil.raycastFromScreenPoint(point: Vector2, params: RaycastParams?)
	local origin, dir = CursorRayUtil.screenPointToRay(point)
	if not origin then return nil end
	return workspace:Raycast(origin, dir * 10000, params)
end

-- Raycast from mouse location
function CursorRayUtil.raycastMouse(params: RaycastParams?)
	local origin, dir = CursorRayUtil.mouseRay()
	if not origin then return nil end
	return workspace:Raycast(origin, dir * 10000, params)
end

-- Project a screen point into world space at a given depth (studs in front of the camera)
function CursorRayUtil.worldPointFromScreen(point: Vector2, depth: number)
	local origin, dir = CursorRayUtil.screenPointToRay(point, depth or 10)
	if not origin then return nil end
	return origin + dir
end

-- World point from current mouse position
function CursorRayUtil.worldPointFromMouse(depth: number)
	local origin, dir = CursorRayUtil.mouseRay(depth or 10)
	if not origin then return nil end
	return origin + dir
end

return CursorRayUtil
