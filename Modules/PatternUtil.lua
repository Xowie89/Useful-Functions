-- PatternUtil.lua
-- String pattern helpers for Luau (Lua patterns, not full regex)
-- API:
--   escapePattern(s) -> string            -- escape magic chars so s is treated literally
--   findAll(s, pattern, init?) -> { {start:number, finish:number, captures:{any}} }
--   matchAll(s, pattern) -> { any | {any} } -- returns captures per match (single or table)
--   replace(s, pattern, repl, n?) -> (string, number) -- uses gsub with optional limit n
--   count(s, pattern) -> number
--   splitByPattern(s, pattern) -> {string}
--   startsWithPattern(s, pattern) -> boolean
--   endsWithPattern(s, pattern) -> boolean
--   wildcardToPattern(glob: string) -> string -- converts * and ? wildcards into a Lua pattern (anchored)

local PatternUtil = {}

local MAGIC_CHARS_CLASS = "([%(%)%.%%%+%-%*%?%[%^%$])" -- capture class of magic characters

function PatternUtil.escapePattern(s: string): string
	return (string.gsub(s, MAGIC_CHARS_CLASS, "%%%1"))
end

-- Return all occurrences of pattern with start/finish and captures
function PatternUtil.findAll(s: string, pattern: string, init: number?): { [number]: { start: number, finish: number, captures: {any} } }
	local out = {}
	local i = init or 1
	local lastEnd = 0
	while i <= #s + 1 do
		local res = { string.find(s, pattern, i) }
		local a = res[1]
		local b = res[2]
		if not a then break end
		local caps = {}
		for idx = 3, #res do caps[#caps+1] = res[idx] end
		out[#out+1] = { start = a, finish = b, captures = caps }
		-- Avoid infinite loop on empty matches by advancing at least 1 char
		i = (b and b or i) + 1
		if i <= lastEnd then i = lastEnd + 1 end
		lastEnd = b or i
	end
	return out
end

-- Collect all matches via gmatch; returns captures or matched text
function PatternUtil.matchAll(s: string, pattern: string): {any}
	local out = {}
	for ... in string.gmatch(s, pattern) do
		local packed = table.pack(...)
		if packed.n == 0 then
			-- No capture groups: gmatch returns entire match implicitly (not as a return); emulate by using findAll fallback
			-- We'll just capture via findAll of a simple group around the pattern
			for ... in string.gmatch(s, "(" .. pattern .. ")") do
				local p2 = table.pack(...)
				out[#out+1] = (p2.n == 1) and p2[1] or p2
			end
			break
		elseif packed.n == 1 then
			out[#out+1] = packed[1]
		else
			local row = {}
			for i = 1, packed.n do row[i] = packed[i] end
			out[#out+1] = row
		end
	end
	return out
end

-- Replace with optional limit n (Lua's gsub supports n); return new string and count
function PatternUtil.replace(s: string, pattern: string, repl: any, n: number?): (string, number)
	return string.gsub(s, pattern, repl, n)
end

function PatternUtil.count(s: string, pattern: string): number
	if pattern == "" then return 0 end
	local _, n = string.gsub(s, pattern, "")
	return n
end

function PatternUtil.splitByPattern(s: string, pattern: string): {string}
	local res = {}
	local last = 1
	if pattern == "" then
		for i = 1, #s do res[i] = string.sub(s, i, i) end
		return res
	end
	while true do
		local a, b = string.find(s, pattern, last)
		if not a then
			res[#res+1] = string.sub(s, last)
			break
		end
		res[#res+1] = string.sub(s, last, a - 1)
		last = (b >= a) and (b + 1) or (last + 1) -- guard empty matches
		if last > #s + 1 then break end
	end
	return res
end

local function ensureStartAnchor(pat: string): string
	if string.sub(pat, 1, 1) ~= "^" then return "^" .. pat end
	return pat
end

local function ensureEndAnchor(pat: string): string
	if string.sub(pat, -1) ~= "$" then return pat .. "$" end
	return pat
end

function PatternUtil.startsWithPattern(s: string, pattern: string): boolean
	local pat = ensureStartAnchor(pattern)
	return string.find(s, pat) ~= nil
end

function PatternUtil.endsWithPattern(s: string, pattern: string): boolean
	local pat = ensureEndAnchor(pattern)
	return string.find(s, pat) ~= nil
end

-- Convert simple wildcard pattern to a Lua pattern and anchor it
-- * -> .*  and  ? -> .
function PatternUtil.wildcardToPattern(glob: string): string
	local pat = PatternUtil.escapePattern(glob)
	pat = string.gsub(pat, "%%%*", ".*")
	pat = string.gsub(pat, "%%%?", ".")
	return "^" .. pat .. "$"
end

return PatternUtil