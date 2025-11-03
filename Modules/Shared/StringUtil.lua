-- StringUtil.lua
-- Common string helpers for Roblox Luau
-- API:
--   trim, ltrim, rtrim
--   split(s, sep[, plain]) -> {string}
--   join(list, sep) -> string
--   startsWith, endsWith
--   capitalize(s), toTitleCase(s)
--   padLeft, padRight
--   slugify(s)
--   formatThousands(number) -> string

local StringUtil = {}

local function isWhitespace(c: string)
	return c == " " or c == "\t" or c == "\n" or c == "\r"
end

function StringUtil.ltrim(s: string): string
	local i = 1
	while i <= #s and isWhitespace(string.sub(s, i, i)) do
		i += 1
	end
	return string.sub(s, i)
end

function StringUtil.rtrim(s: string): string
	local i = #s
	while i >= 1 and isWhitespace(string.sub(s, i, i)) do
		i -= 1
	end
	return string.sub(s, 1, i)
end

function StringUtil.trim(s: string): string
	return StringUtil.rtrim(StringUtil.ltrim(s))
end

-- Split by a separator. If plain=true, treat sep as plain text (no patterns)
function StringUtil.split(s: string, sep: string, plain: boolean?): {string}
	if string.split then
		-- Roblox provides string.split (plain)
		return string.split(s, sep)
	end
	local out = {}
	local pattern = plain and sep or string.format("([^%s]+)", sep)
	for part in string.gmatch(s, pattern) do
		table.insert(out, part)
	end
	return out
end

function StringUtil.join(list: {string}, sep: string): string
	return table.concat(list, sep)
end

function StringUtil.startsWith(s: string, prefix: string): boolean
	return string.sub(s, 1, #prefix) == prefix
end

function StringUtil.endsWith(s: string, suffix: string): boolean
	return string.sub(s, -#suffix) == suffix
end

function StringUtil.capitalize(s: string): string
	if #s == 0 then return s end
	return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
end

function StringUtil.toTitleCase(s: string): string
	return (string.gsub(string.lower(s), "(%a)([%w_']*)", function(first, rest)
		return string.upper(first) .. rest
	end))
end

function StringUtil.padLeft(s: string, len: number, ch: string?): string
	ch = ch or " "
	if #s >= len then return s end
	return string.rep(ch, len - #s) .. s
end

function StringUtil.padRight(s: string, len: number, ch: string?): string
	ch = ch or " "
	if #s >= len then return s end
	return s .. string.rep(ch, len - #s)
end

function StringUtil.slugify(s: string): string
	-- Lowercase, replace non-alnum with '-', collapse repeats, trim '-'
	s = string.lower(s)
	s = (string.gsub(s, "[^%w]+", "-"))
	s = (string.gsub(s, "%-+", "-"))
	s = (string.gsub(s, "^%-+", ""))
	s = (string.gsub(s, "%-+$", ""))
	return s
end

function StringUtil.formatThousands(n: number): string
	local s = tostring(math.floor(n))
	local sign = ""
	if string.sub(s, 1, 1) == "-" then
		sign = "-"
		s = string.sub(s, 2)
	end
	local res = s
	local k
	repeat
		res, k = string.gsub(res, "^(%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return sign .. res
end

return StringUtil