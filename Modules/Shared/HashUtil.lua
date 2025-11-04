-- Modules/Shared/HashUtil.lua
-- Lightweight non-crypto hashing and stable table hashing

local HttpService = game:GetService("HttpService")

local HashUtil = {}

-- DJB2 string hash (non-crypto)
function HashUtil.stringHash(s: string): number
	local h = 5381
	for i = 1, #s do
		h = ((h << 5) + h) ~ string.byte(s, i) -- h*33 ^ c
		h = h & 0xFFFFFFFF -- keep in 32-bit range
	end
	return h
end

local function normalize(value)
	local t = typeof(value)
	if t ~= "table" and t ~= "Instance" then return value end
	if t == "Instance" then return value:GetFullName() end
	-- table: sort keys for stable order
	local keys = {}
	for k in pairs(value) do keys[#keys+1] = k end
	table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
	local out = {}
	for _, k in ipairs(keys) do
		out[#out+1] = { key = normalize(k), value = normalize(value[k]) }
	end
	return out
end

function HashUtil.stableHash(value): number
	local ok, serialized = pcall(function()
		return HttpService:JSONEncode(normalize(value))
	end)
	if not ok then
		return 0
	end
	return HashUtil.stringHash(serialized)
end

return HashUtil
