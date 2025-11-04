-- Modules/Shared/FormatUtil.lua
-- Formatting helpers for numbers, percentages, bytes, and time-ish strings

local FormatUtil = {}

local suffixes = {
	{1e12, "T"},
	{1e9, "B"},
	{1e6, "M"},
	{1e3, "k"},
}

local function roundTo(n, decimals)
	local m = 10 ^ (decimals or 0)
	return math.floor(n * m + 0.5) / m
end

function FormatUtil.withCommas(n: number): string
	local s = tostring(math.floor(n))
	local sign = s:sub(1, 1) == "-" and "-" or ""
	s = s:gsub("^-", "")
	local left, num = s:match("^(%d+)(%d%d%d)")
	while left do
		s = s:gsub("^(%d+)(%d%d%d)", "%1,%2")
		left, num = s:match("^(%d+)(%d%d%d)")
	end
	return sign .. s
end

function FormatUtil.abbreviate(n: number, decimals: number?): string
	local sign = n < 0 and -1 or 1
	n = math.abs(n)
	for _, pair in ipairs(suffixes) do
		local value, label = pair[1], pair[2]
		if n >= value then
			return string.format("%0.*f%s", decimals or 1, roundTo(n / value, decimals or 1), label)
		end
	end
	return string.format("%d", n * sign)
end

function FormatUtil.percent(n: number, decimals: number?): string
	return string.format("%0.*f%%", decimals or 0, roundTo(n * 100, decimals or 0))
end

local byteUnits = {"B", "KB", "MB", "GB", "TB"}
function FormatUtil.bytes(n: number, decimals: number?): string
	n = math.max(n, 0)
	local i = 1
	while n >= 1024 and i < #byteUnits do
		n = n / 1024
		i += 1
	end
	return string.format("%0.*f %s", decimals or 1, roundTo(n, decimals or 1), byteUnits[i])
end

function FormatUtil.timeAgo(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	if seconds < 60 then return seconds .. "s ago" end
	local minutes = math.floor(seconds / 60)
	if minutes < 60 then return minutes .. "m ago" end
	local hours = math.floor(minutes / 60)
	if hours < 24 then return hours .. "h ago" end
	local days = math.floor(hours / 24)
	return days .. "d ago"
end

return FormatUtil
