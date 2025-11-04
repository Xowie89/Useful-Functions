-- Modules/Server/CharacterScaleUtil.lua
-- Server-side utilities to resize player characters (R15 humanoids)
-- Supports setting/tweening BodyHeightScale, BodyWidthScale, BodyDepthScale, and HeadScale.

local TweenService = game:GetService("TweenService")

local CharacterScaleUtil = {}

local SCALE_NAMES = {
	height = "BodyHeightScale",
	width = "BodyWidthScale",
	depth = "BodyDepthScale",
	head = "HeadScale",
}

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

local function clamp(v, minV, maxV)
	return math.clamp(v, minV, maxV)
end

local function getOrCreateScaleValue(humanoid, name)
	local obj = humanoid:FindFirstChild(name)
	if obj and obj:IsA("NumberValue") then return obj end
	-- Create if missing (works for R15); for R6 this won't do anything visible
	obj = Instance.new("NumberValue")
	obj.Name = name
	obj.Value = 1
	obj.Parent = humanoid
	return obj
end

local function ensureScaleValues(humanoid)
	return {
		height = getOrCreateScaleValue(humanoid, SCALE_NAMES.height),
		width = getOrCreateScaleValue(humanoid, SCALE_NAMES.width),
		depth = getOrCreateScaleValue(humanoid, SCALE_NAMES.depth),
		head = getOrCreateScaleValue(humanoid, SCALE_NAMES.head),
	}
end

local DEFAULT_MIN, DEFAULT_MAX = 0.5, 2.0

-- Returns a table of current scales { height, width, depth, head }
function CharacterScaleUtil.getScales(target)
	local humanoid = toHumanoid(target)
	if not humanoid then return nil, "Humanoid not found" end
	local s = ensureScaleValues(humanoid)
	return {
		height = s.height.Value,
		width = s.width.Value,
		depth = s.depth.Value,
		head = s.head.Value,
	}
end

-- Set individual scales. scales can have height/width/depth/head; missing fields are left unchanged.
-- options: { min = number, max = number }
function CharacterScaleUtil.setScale(target, scales, options)
	local humanoid = toHumanoid(target)
	if not humanoid then return false, "Humanoid not found" end
	scales = scales or {}
	options = options or {}
	local minV = options.min or DEFAULT_MIN
	local maxV = options.max or DEFAULT_MAX
	local s = ensureScaleValues(humanoid)
	if scales.height then s.height.Value = clamp(scales.height, minV, maxV) end
	if scales.width then s.width.Value = clamp(scales.width, minV, maxV) end
	if scales.depth then s.depth.Value = clamp(scales.depth, minV, maxV) end
	if scales.head then s.head.Value = clamp(scales.head, minV, maxV) end
	return true
end

-- Set all scales uniformly to the same value.
function CharacterScaleUtil.setUniformScale(target, scale, options)
	return CharacterScaleUtil.setScale(target, {
		height = scale,
		width = scale,
		depth = scale,
		head = scale,
	}, options)
end

-- Tween to given scales over time using TweenInfo; missing fields remain unchanged.
function CharacterScaleUtil.tweenScale(target, scales, tweenInfo, options)
	local humanoid = toHumanoid(target)
	if not humanoid then return false, "Humanoid not found" end
	scales = scales or {}
	options = options or {}
	local minV = options.min or DEFAULT_MIN
	local maxV = options.max or DEFAULT_MAX
	local s = ensureScaleValues(humanoid)
	local any
	if scales.height then any = TweenService:Create(s.height, tweenInfo, { Value = clamp(scales.height, minV, maxV) }) end
	if scales.width then any = TweenService:Create(s.width, tweenInfo, { Value = clamp(scales.width, minV, maxV) }) end
	if scales.depth then any = TweenService:Create(s.depth, tweenInfo, { Value = clamp(scales.depth, minV, maxV) }) end
	if scales.head then any = TweenService:Create(s.head, tweenInfo, { Value = clamp(scales.head, minV, maxV) }) end
	-- Play tweens (create separate tweens for each present field)
	local tweens = {}
	if scales.height then tweens[#tweens+1] = TweenService:Create(s.height, tweenInfo, { Value = clamp(scales.height, minV, maxV) }) end
	if scales.width then tweens[#tweens+1] = TweenService:Create(s.width, tweenInfo, { Value = clamp(scales.width, minV, maxV) }) end
	if scales.depth then tweens[#tweens+1] = TweenService:Create(s.depth, tweenInfo, { Value = clamp(scales.depth, minV, maxV) }) end
	if scales.head then tweens[#tweens+1] = TweenService:Create(s.head, tweenInfo, { Value = clamp(scales.head, minV, maxV) }) end
	for _, t in ipairs(tweens) do t:Play() end
	return true, tweens
end

function CharacterScaleUtil.tweenUniformScale(target, scale, tweenInfo, options)
	return CharacterScaleUtil.tweenScale(target, {
		height = scale,
		width = scale,
		depth = scale,
		head = scale,
	}, tweenInfo, options)
end

function CharacterScaleUtil.reset(target)
	return CharacterScaleUtil.setUniformScale(target, 1)
end

return CharacterScaleUtil
