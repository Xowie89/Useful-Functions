-- MathUtil.lua
-- Common math helpers for Roblox Luau
-- API:
--   clamp, lerp, invLerp, remap
--   round(n, decimals?), roundTo(n, increment), floorTo, ceilTo
--   approxEqual(a, b, eps?)
--   randomRange(min, max, integer?)
--   chooseWeighted({ {item=..., weight=...}, ... })

local MathUtil = {}

function MathUtil.clamp(n: number, minV: number, maxV: number): number
	if n < minV then return minV end
	if n > maxV then return maxV end
	return n
end

function MathUtil.lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

function MathUtil.invLerp(a: number, b: number, v: number): number
	if a == b then return 0 end
	return (v - a) / (b - a)
end

function MathUtil.remap(v: number, inMin: number, inMax: number, outMin: number, outMax: number, doClamp: boolean?): number
	local t = MathUtil.invLerp(inMin, inMax, v)
	if doClamp then t = MathUtil.clamp(t, 0, 1) end
	return MathUtil.lerp(outMin, outMax, t)
end

function MathUtil.round(n: number, decimals: number?): number
	decimals = decimals or 0
	local m = 10 ^ decimals
	return math.floor(n * m + 0.5) / m
end

function MathUtil.roundTo(n: number, increment: number): number
	local i = increment or 1
	return math.floor((n / i) + 0.5) * i
end

function MathUtil.floorTo(n: number, increment: number): number
	local i = increment or 1
	return math.floor(n / i) * i
end

function MathUtil.ceilTo(n: number, increment: number): number
	local i = increment or 1
	return math.ceil(n / i) * i
end

function MathUtil.approxEqual(a: number, b: number, eps: number?): boolean
	eps = eps or 1e-4
	return math.abs(a - b) <= eps
end

function MathUtil.randomRange(min: number, max: number, integer: boolean?): number
	if integer then
		return math.random(min, max)
	else
		return min + math.random() * (max - min)
	end
end

function MathUtil.chooseWeighted(entries: { {item: any, weight: number} }): any
	local total = 0
	for _, e in ipairs(entries) do
		total += e.weight
	end
	if total <= 0 then return nil end
	local r = MathUtil.randomRange(0, total, false)
	local accum = 0
	for _, e in ipairs(entries) do
		accum += e.weight
		if r <= accum then
			return e.item
		end
	end
	return entries[#entries] and entries[#entries].item or nil
end

return MathUtil