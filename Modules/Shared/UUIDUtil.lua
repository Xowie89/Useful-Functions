-- Modules/Shared/UUIDUtil.lua
-- GUIDs and random strings

local HttpService = game:GetService("HttpService")

local UUIDUtil = {}

function UUIDUtil.guid(): string
	return HttpService:GenerateGUID(false)
end

local DEFAULT_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
function UUIDUtil.randomString(length: number?, charset: string?): string
	length = length or 16
	charset = charset or DEFAULT_CHARS
	local result = table.create(length)
	for i = 1, length do
		local idx = math.random(1, #charset)
		result[i] = string.sub(charset, idx, idx)
	end
	return table.concat(result)
end

-- Short id derived from a GUID (base36-ish by stripping hyphens)
function UUIDUtil.shortId(length: number?): string
	local g = UUIDUtil.guid():gsub("-", "")
	length = math.clamp(length or 12, 4, #g)
	return string.sub(g, 1, length)
end

return UUIDUtil
