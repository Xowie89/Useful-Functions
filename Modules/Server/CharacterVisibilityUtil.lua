-- Modules/Server/CharacterVisibilityUtil.lua
-- Server-side utilities for character visibility and collisions

local CharacterVisibilityUtil = {}

local function isHumanoid(x)
	return typeof(x) == "Instance" and x:IsA("Humanoid")
end

local function toCharacter(target)
	if typeof(target) == "Instance" and target:IsA("Model") then
		return target
	end
	if isHumanoid(target) then
		return target.Parent
	end
	if typeof(target) == "Instance" and target:IsA("Player") then
		local char = target.Character or target.CharacterAdded:Wait()
		return char
	end
	return nil
end

local function setParts(character, setter)
	for _, inst in ipairs(character:GetDescendants()) do
		if inst:IsA("BasePart") then
			setter(inst)
		elseif inst:IsA("Decal") then
			setter(inst)
		end
	end
end

function CharacterVisibilityUtil.setTransparency(target, alpha, options)
	local character = toCharacter(target)
	if not character then return false, "Character not found" end
	options = options or {}
	setParts(character, function(inst)
		if inst:IsA("BasePart") then
			inst.Transparency = alpha
			if options.nonCollide ~= nil then
				inst.CanCollide = not options.nonCollide
			end
		elseif inst:IsA("Decal") then
			inst.Transparency = alpha
		end
	end)
	return true
end

-- Toggle invisibility; options: { nonCollide = true|false }
function CharacterVisibilityUtil.setInvisible(target, enabled, options)
	options = options or {}
	local alpha = enabled and 1 or 0
	return CharacterVisibilityUtil.setTransparency(target, alpha, options)
end

-- Ghost mode: non-colliding but still visible
function CharacterVisibilityUtil.setGhostMode(target, enabled)
	local character = toCharacter(target)
	if not character then return false, "Character not found" end
	setParts(character, function(inst)
		if inst:IsA("BasePart") then
			inst.CanCollide = not enabled
		end
	end)
	return true
end

return CharacterVisibilityUtil
