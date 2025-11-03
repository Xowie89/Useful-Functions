-- RaycastUtil.lua
-- Helpers for common raycast operations
-- API:
--   RaycastUtil.params(includeOrExclude: {Instance}?, mode: 'Include'|'Exclude'?) -> RaycastParams
--   RaycastUtil.raycast(origin: Vector3, direction: Vector3, params?: RaycastParams) -> RaycastResult?
--   RaycastUtil.raycastFromTo(a: Vector3, b: Vector3, params?: RaycastParams) -> RaycastResult?
--   RaycastUtil.ground(position: Vector3, maxDistance: number?, params?: RaycastParams) -> RaycastResult?
--   RaycastUtil.ignoreCharacter(params: RaycastParams, playerOrCharacter: Player|Model)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local RaycastUtil = {}

function RaycastUtil.params(list: {Instance}?, mode: string?)
	local p = RaycastParams.new()
	if list and #list > 0 then
		p.FilterDescendantsInstances = list
	end
	if mode == "Include" then
		p.FilterType = Enum.RaycastFilterType.Include
	else
		p.FilterType = Enum.RaycastFilterType.Exclude
	end
	p.IgnoreWater = false
	return p
end

function RaycastUtil.ignoreCharacter(params: RaycastParams, who: any)
	local character: Instance? = nil
	if typeof(who) == "Instance" and who:IsA("Player") then
		character = who.Character
	elseif typeof(who) == "Instance" then
		character = who
	end
	if character then
		local current = params.FilterDescendantsInstances
		local newList = {}
		for i = 1, #(current or {}) do newList[i] = current[i] end
		table.insert(newList, character)
		params.FilterDescendantsInstances = newList
	end
end

function RaycastUtil.raycast(origin: Vector3, direction: Vector3, params: RaycastParams?)
	return Workspace:Raycast(origin, direction, params)
end

function RaycastUtil.raycastFromTo(a: Vector3, b: Vector3, params: RaycastParams?)
	return Workspace:Raycast(a, b - a, params)
end

function RaycastUtil.ground(position: Vector3, maxDistance: number?, params: RaycastParams?)
	maxDistance = maxDistance or 1024
	return Workspace:Raycast(position, Vector3.new(0, -maxDistance, 0), params)
end

return RaycastUtil