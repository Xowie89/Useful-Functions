-- CooldownUtil.lua
-- Track per-key cooldowns on client or server
-- API:
--   local cd = CooldownUtil.new(defaultDuration:number)
--   cd:set(key, duration?) -- set/override duration for key
--   cd:use(key) -> boolean -- try to use; returns true if allowed and starts cooldown
--   cd:canUse(key) -> boolean
--   cd:timeRemaining(key) -> number
--   cd:clear(key)

local CooldownUtil = {}
CooldownUtil.__index = CooldownUtil

function CooldownUtil.new(defaultDuration: number)
	local self = setmetatable({}, CooldownUtil)
	self._default = defaultDuration or 1
	self._ends = {} -- key -> os.clock end time
	self._durations = {} -- key -> duration override
	return self
end

function CooldownUtil:set(key: string, duration: number?)
	if duration and duration > 0 then
		self._durations[key] = duration
	else
		self._durations[key] = nil
	end
end

function CooldownUtil:timeRemaining(key: string)
	local t = self._ends[key]
	if not t then return 0 end
	return math.max(0, t - os.clock())
end

function CooldownUtil:canUse(key: string)
	return self:timeRemaining(key) <= 0
end

function CooldownUtil:use(key: string)
	if not self:canUse(key) then return false end
	local d = self._durations[key] or self._default
	self._ends[key] = os.clock() + d
	return true
end

function CooldownUtil:clear(key: string)
	self._ends[key] = nil
end

return CooldownUtil