-- ColorUtil.lua
-- Color3 helpers: hex/RGB conversion, lerp, lighten/darken
-- API:
--   fromHex("#RRGGBB"|"RRGGBB") -> Color3
--   toHex(Color3) -> "#RRGGBB"
--   fromRGB(r,g,b) -> Color3, toRGB(Color3) -> (r,g,b)
--   lerp(a,b,t) -> Color3
--   lighten(c, factor), darken(c, factor)

local ColorUtil = {}

local function clamp01(x: number)
	if x < 0 then return 0 end
	if x > 1 then return 1 end
	return x
end

local function toByte(x: number)
	return math.clamp(math.floor(x * 255 + 0.5), 0, 255)
end

function ColorUtil.fromHex(hex: string): Color3
	hex = string.lower(hex)
	hex = string.gsub(hex, "#", "")
	assert(#hex == 6, "fromHex expects 6 hex digits")
	local r = tonumber(string.sub(hex, 1, 2), 16)
	local g = tonumber(string.sub(hex, 3, 4), 16)
	local b = tonumber(string.sub(hex, 5, 6), 16)
	return Color3.fromRGB(r, g, b)
end

function ColorUtil.toHex(c: Color3): string
	local r, g, b = toByte(c.R), toByte(c.G), toByte(c.B)
	return string.format("#%02X%02X%02X", r, g, b)
end

function ColorUtil.fromRGB(r: number, g: number, b: number): Color3
	return Color3.fromRGB(r, g, b)
end

function ColorUtil.toRGB(c: Color3): (number, number, number)
	return toByte(c.R), toByte(c.G), toByte(c.B)
end

function ColorUtil.lerp(a: Color3, b: Color3, t: number): Color3
	return a:lerp(b, t)
end

function ColorUtil.lighten(c: Color3, factor: number): Color3
	factor = math.clamp(factor or 0.1, 0, 1)
	return Color3.new(
		clamp01(c.R + (1 - c.R) * factor),
		clamp01(c.G + (1 - c.G) * factor),
		clamp01(c.B + (1 - c.B) * factor)
	)
end

function ColorUtil.darken(c: Color3, factor: number): Color3
	factor = math.clamp(factor or 0.1, 0, 1)
	return Color3.new(
		clamp01(c.R * (1 - factor)),
		clamp01(c.G * (1 - factor)),
		clamp01(c.B * (1 - factor))
	)
end

return ColorUtil