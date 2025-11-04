-- Modules/Server/CharacterMovementUtil.lua
-- Server-side utilities to adjust humanoid movement properties

local CharacterMovementUtil = {}

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

local function apply(h, props)
	for k, v in pairs(props) do
		pcall(function()
			h[k] = v
		end)
	end
end

function CharacterMovementUtil.get(humanoidOrTarget)
	local h = toHumanoid(humanoidOrTarget)
	if not h then return nil, "Humanoid not found" end
	return {
		WalkSpeed = h.WalkSpeed,
		JumpPower = h.UseJumpPower and h.JumpPower or nil,
		JumpHeight = (not h.UseJumpPower) and h.JumpHeight or nil,
		AutoRotate = h.AutoRotate,
		HipHeight = h.HipHeight,
		MaxSlopeAngle = h.MaxSlopeAngle,
	}
end

function CharacterMovementUtil.set(humanoidOrTarget, props)
	local h = toHumanoid(humanoidOrTarget)
	if not h then return false, "Humanoid not found" end
	apply(h, props or {})
	return true
end

function CharacterMovementUtil.setWalkSpeed(target, speed)
	return CharacterMovementUtil.set(target, { WalkSpeed = speed })
end

function CharacterMovementUtil.setJumpPower(target, power)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	h.UseJumpPower = true
	h.JumpPower = power
	return true
end

function CharacterMovementUtil.setJumpHeight(target, height)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	h.UseJumpPower = false
	h.JumpHeight = height
	return true
end

function CharacterMovementUtil.setAutoRotate(target, enabled)
	return CharacterMovementUtil.set(target, { AutoRotate = enabled })
end

function CharacterMovementUtil.setHipHeight(target, height)
	return CharacterMovementUtil.set(target, { HipHeight = height })
end

-- Applies a temporary modifier to WalkSpeed (absolute value or additive/multiplier via options)
-- options: { mode = "set"|"add"|"mul" (default "set"), duration = number }
function CharacterMovementUtil.tempWalkSpeed(target, value, options)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	options = options or {}
	local prev = h.WalkSpeed
	local mode = options.mode or "set"
	if mode == "add" then
		h.WalkSpeed = prev + value
	elseif mode == "mul" then
		h.WalkSpeed = prev * value
	else
		h.WalkSpeed = value
	end
	local function restore()
		if h and h.Parent then
			h.WalkSpeed = prev
		end
	end
	if options.duration and options.duration > 0 then
		task.delay(options.duration, restore)
	end
	return true, restore
end

-- Applies multiple movement modifiers at once and returns a restore function
function CharacterMovementUtil.apply(target, props)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	local before = CharacterMovementUtil.get(h)
	CharacterMovementUtil.set(h, props)
	local function restore()
		if h and h.Parent then
			CharacterMovementUtil.set(h, before)
		end
	end
	return true, restore
end

return CharacterMovementUtil
