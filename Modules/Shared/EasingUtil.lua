-- Modules/Shared/EasingUtil.lua
-- Robert Penner-like easing functions on t in [0,1]

local EasingUtil = {}

local function clamp01(t) return math.clamp(t, 0, 1) end

function EasingUtil.linear(t) return clamp01(t) end

local function easeInPow(t, p) t = clamp01(t); return t ^ p end
local function easeOutPow(t, p) t = clamp01(t); return 1 - (1 - t) ^ p end
local function easeInOutPow(t, p)
	t = clamp01(t)
	if t < 0.5 then return 0.5 * (2 * t) ^ p end
	return 1 - 0.5 * (2 * (1 - t)) ^ p
end

function EasingUtil.quadIn(t) return easeInPow(t, 2) end
function EasingUtil.quadOut(t) return easeOutPow(t, 2) end
function EasingUtil.quadInOut(t) return easeInOutPow(t, 2) end

function EasingUtil.cubicIn(t) return easeInPow(t, 3) end
function EasingUtil.cubicOut(t) return easeOutPow(t, 3) end
function EasingUtil.cubicInOut(t) return easeInOutPow(t, 3) end

function EasingUtil.quartIn(t) return easeInPow(t, 4) end
function EasingUtil.quartOut(t) return easeOutPow(t, 4) end
function EasingUtil.quartInOut(t) return easeInOutPow(t, 4) end

function EasingUtil.quintIn(t) return easeInPow(t, 5) end
function EasingUtil.quintOut(t) return easeOutPow(t, 5) end
function EasingUtil.quintInOut(t) return easeInOutPow(t, 5) end

function EasingUtil.sineIn(t) t = clamp01(t); return 1 - math.cos((t * math.pi) / 2) end
function EasingUtil.sineOut(t) t = clamp01(t); return math.sin((t * math.pi) / 2) end
function EasingUtil.sineInOut(t) t = clamp01(t); return -(math.cos(math.pi * t) - 1) / 2 end

function EasingUtil.expoIn(t) t = clamp01(t); return (t == 0) and 0 or 2 ^ (10 * (t - 1)) end
function EasingUtil.expoOut(t) t = clamp01(t); return (t == 1) and 1 or 1 - 2 ^ (-10 * t) end
function EasingUtil.expoInOut(t)
	t = clamp01(t)
	if t == 0 or t == 1 then return t end
	if t < 0.5 then return 0.5 * 2 ^ (20 * t - 10) end
	return 1 - 0.5 * 2 ^ (-20 * t + 10)
end

function EasingUtil.circIn(t) t = clamp01(t); return 1 - math.sqrt(1 - t * t) end
function EasingUtil.circOut(t) t = clamp01(t); return math.sqrt(1 - (t - 1) ^ 2) end
function EasingUtil.circInOut(t)
	t = clamp01(t)
	if t < 0.5 then return (1 - math.sqrt(1 - (2 * t) ^ 2)) / 2 end
	return (math.sqrt(1 - (-2 * t + 2) ^ 2) + 1) / 2
end

function EasingUtil.backIn(t, s)
	t = clamp01(t); s = s or 1.70158
	return (s + 1) * t ^ 3 - s * t ^ 2
end
function EasingUtil.backOut(t, s)
	t = clamp01(t); s = s or 1.70158
	t = t - 1
	return 1 + (s + 1) * t ^ 3 + s * t ^ 2
end
function EasingUtil.backInOut(t, s)
	t = clamp01(t); s = (s or 1.70158) * 1.525
	if t < 0.5 then return ((2 * t) ^ 2 * (((s + 1) * 2 * t) - s)) / 2 end
	t = 2 * t - 2
	return (t ^ 2 * (((s + 1) * t) + s) + 2) / 2
end

local function bounceOut(t)
	local n1 = 7.5625
	local d1 = 2.75
	if t < 1 / d1 then return n1 * t * t end
	if t < 2 / d1 then t = t - 1.5 / d1; return n1 * t * t + 0.75 end
	if t < 2.5 / d1 then t = t - 2.25 / d1; return n1 * t * t + 0.9375 end
	t = t - 2.625 / d1; return n1 * t * t + 0.984375
end
function EasingUtil.bounceIn(t) t = clamp01(t); return 1 - bounceOut(1 - t) end
function EasingUtil.bounceOut(t) t = clamp01(t); return bounceOut(t) end
function EasingUtil.bounceInOut(t)
	t = clamp01(t)
	if t < 0.5 then return (1 - bounceOut(1 - 2 * t)) / 2 end
	return (1 + bounceOut(2 * t - 1)) / 2
end

function EasingUtil.elasticIn(t, a, p)
	t = clamp01(t); a = a or 1; p = p or 0.3
	if t == 0 or t == 1 then return t end
	local s = p / (2 * math.pi) * math.asin(1 / a)
	return -(a * 2 ^ (10 * (t - 1)) * math.sin((t - 1 - s) * (2 * math.pi) / p))
end
function EasingUtil.elasticOut(t, a, p)
	t = clamp01(t); a = a or 1; p = p or 0.3
	if t == 0 or t == 1 then return t end
	local s = p / (2 * math.pi) * math.asin(1 / a)
	return a * 2 ^ (-10 * t) * math.sin((t - s) * (2 * math.pi) / p) + 1
end
function EasingUtil.elasticInOut(t, a, p)
	t = clamp01(t); a = a or 1; p = p or 0.45
	if t == 0 or t == 1 then return t end
	local s = p / (2 * math.pi) * math.asin(1 / a)
	if t < 0.5 then
		return -0.5 * (a * 2 ^ (20 * t - 10) * math.sin(((2 * t - 1) - s) * (2 * math.pi) / p))
	end
	return a * 2 ^ (-20 * t + 10) * math.sin(((2 * t - 1) - s) * (2 * math.pi) / p) * 0.5 + 1
end

return EasingUtil
