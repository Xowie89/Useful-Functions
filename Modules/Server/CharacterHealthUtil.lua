-- Modules/Server/CharacterHealthUtil.lua
-- Server-side utilities for humanoid health and invulnerability

local CharacterHealthUtil = {}

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

function CharacterHealthUtil.setMaxHealth(target, maxHealth, options)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	options = options or {}
	h.MaxHealth = maxHealth
	if options.clamp ~= false then
		h.Health = math.min(h.Health, h.MaxHealth)
	end
	return true
end

function CharacterHealthUtil.heal(target, amount)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	h.Health = math.clamp(h.Health + amount, 0, h.MaxHealth)
	return true
end

function CharacterHealthUtil.damage(target, amount)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	h.Health = math.clamp(h.Health - amount, 0, h.MaxHealth)
	return true
end

-- Simple invulnerability: prevents health from decreasing below the last known value.
-- Returns: (true, restoreFn) on enable; (true) on disable
local INV = setmetatable({}, { __mode = "k" })

function CharacterHealthUtil.setInvulnerable(target, enabled, options)
	local h = toHumanoid(target)
	if not h then return false, "Humanoid not found" end
	options = options or {}
	local data = INV[h]
	local function disable()
		local d = INV[h]
		if d then
			if d.conn then d.conn:Disconnect() end
			INV[h] = nil
		end
	end
	if not enabled then
		disable()
		return true
	end
	-- enable
	if data and data.conn then
		data.last = h.Health
	else
		local last = h.Health
		local conn = h.HealthChanged:Connect(function(newHealth)
			if newHealth < last then
				-- prevent decreases
				h.Health = last
			else
				last = newHealth
			end
		end)
		INV[h] = { conn = conn }
	end
	if options.duration and options.duration > 0 then
		task.delay(options.duration, disable)
	end
	return true, disable
end

return CharacterHealthUtil
