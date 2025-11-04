-- Modules/Server/CharacterAppearanceUtil.lua
-- Server-side utilities to alter character appearance (HumanoidDescription, colors, accessories)

local Players = game:GetService("Players")

local CharacterAppearanceUtil = {}

local function isHumanoid(x)
	return typeof(x) == "Instance" and x:IsA("Humanoid")
end

local function toHumanoid(target)
	if isHumanoid(target) then return target end
	if typeof(target) == "Instance" and target:IsA("Player") then
		local char = target.Character or target.CharacterAdded:Wait()
		return char:FindFirstChildOfClass("Humanoid")
	end
	if typeof(target) == "Instance" and target:IsA("Model") then
		return target:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

-- Apply a HumanoidDescription to a target humanoid
function CharacterAppearanceUtil.applyDescription(target, description)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	if typeof(description) ~= "Instance" or not description:IsA("HumanoidDescription") then
		return false, "description must be HumanoidDescription"
	end
	local ok, err = pcall(function()
		h:ApplyDescription(description)
	end)
	return ok, err
end

-- Fetch a HumanoidDescription for a userId and apply it
function CharacterAppearanceUtil.applyUserOutfit(target, userId)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	local ok, descOrErr = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not ok then return false, descOrErr end
	return CharacterAppearanceUtil.applyDescription(h, descOrErr)
end

-- Fetch an outfit by outfitId and apply it
function CharacterAppearanceUtil.applyOutfitId(target, outfitId)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	local ok, descOrErr = pcall(function()
		return Players:GetHumanoidDescriptionFromOutfitId(outfitId)
	end)
	if not ok then return false, descOrErr end
	return CharacterAppearanceUtil.applyDescription(h, descOrErr)
end

-- Ensure BodyColors exists and optionally set colors (BrickColor or Color3)
function CharacterAppearanceUtil.setBodyColors(characterOrTarget, colors)
	local h = toHumanoid(characterOrTarget)
	if not h then return nil, "Humanoid not found" end
	local character = h.Parent
	if not character then return nil, "Character model missing" end
	local bc = character:FindFirstChildOfClass("BodyColors")
	if not bc then
		bc = Instance.new("BodyColors")
		bc.Parent = character
	end
	colors = colors or {}
	local function toBrickColor(v)
		if typeof(v) == "BrickColor" then return v end
		if typeof(v) == "Color3" then return BrickColor.new(v) end
		if type(v) == "string" then return BrickColor.new(v) end
		return nil
	end
	local map = {
		HeadColor = colors.Head,
		LeftArmColor = colors.LeftArm,
		RightArmColor = colors.RightArm,
		LeftLegColor = colors.LeftLeg,
		RightLegColor = colors.RightLeg,
		TorsoColor = colors.Torso,
	}
	for prop, val in pairs(map) do
		if val ~= nil then
			local bcVal = toBrickColor(val)
			if bcVal then
				pcall(function() bc[prop] = bcVal end)
			end
		end
	end
	return bc
end

-- Add an Accessory instance to character (Accessory must be parented afterwards by Humanoid:AddAccessory)
function CharacterAppearanceUtil.addAccessory(target, accessory)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	if typeof(accessory) ~= "Instance" or not accessory:IsA("Accessory") then
		return false, "accessory must be Accessory instance"
	end
	local ok, err = pcall(function()
		h:AddAccessory(accessory)
	end)
	return ok, err
end

-- Remove all accessories or those matching a predicate
function CharacterAppearanceUtil.removeAccessories(target, predicate)
	local h = toHumanoid(target)
	if not h then return 0, "Humanoid not found" end
	local character = h.Parent
	if not character then return 0, "Character model missing" end
	local removed = 0
	for _, inst in ipairs(character:GetChildren()) do
		if inst:IsA("Accessory") then
			if not predicate or predicate(inst) then
				inst:Destroy()
				removed += 1
			end
		end
	end
	return removed
end

-- Quickly set classic clothing asset ids using a transient HumanoidDescription
function CharacterAppearanceUtil.setClothingIds(target, shirtId, pantsId)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	local desc = Instance.new("HumanoidDescription")
	if shirtId then desc.Shirt = tostring(shirtId) end
	if pantsId then desc.Pants = tostring(pantsId) end
	return CharacterAppearanceUtil.applyDescription(h, desc)
end

return CharacterAppearanceUtil
