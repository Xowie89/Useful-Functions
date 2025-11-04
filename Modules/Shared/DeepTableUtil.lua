-- Modules/Shared/DeepTableUtil.lua
-- Deep clone/merge and safe get/set utilities

local DeepTableUtil = {}

local function isArray(t)
	if type(t) ~= "table" then return false end
	local n = 0
	for k in pairs(t) do
		if type(k) ~= "number" then return false end
		n = n + 1
	end
	return n == #t
end

function DeepTableUtil.deepClone(t)
	if type(t) ~= "table" then return t end
	local out = {}
	for k, v in pairs(t) do
		out[DeepTableUtil.deepClone(k)] = DeepTableUtil.deepClone(v)
	end
	return out
end

function DeepTableUtil.deepMerge(dest, src)
	if type(dest) ~= "table" then dest = {} end
	if type(src) ~= "table" then return dest end
	for k, v in pairs(src) do
		if type(v) == "table" and type(dest[k]) == "table" then
			dest[k] = DeepTableUtil.deepMerge(dest[k], v)
		else
			dest[k] = DeepTableUtil.deepClone(v)
		end
	end
	return dest
end

function DeepTableUtil.getIn(t, path, default)
	local cur = t
	for i = 1, #path do
		if type(cur) ~= "table" then return default end
		cur = cur[path[i]]
		if cur == nil then return default end
	end
	return cur
end

-- Immutable-style setIn: returns a new table with the path set to value
function DeepTableUtil.setIn(t, path, value)
	local function cloneShallow(x)
		local r = {}
		for k, v in pairs(x) do r[k] = v end
		return r
	end
	local function setRec(cur, i)
		local out = type(cur) == "table" and cloneShallow(cur) or {}
		if i > #path then
			return DeepTableUtil.deepClone(value)
		end
		local key = path[i]
		out[key] = setRec(out[key], i + 1)
		return out
	end
	return setRec(t or {}, 1)
end

function DeepTableUtil.equalsDeep(a, b)
	if a == b then return true end
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	local seen = {}
	for k in pairs(a) do seen[k] = true end
	for k in pairs(b) do seen[k] = true end
	for k in pairs(seen) do
		if not DeepTableUtil.equalsDeep(a[k], b[k]) then return false end
	end
	return true
end

return DeepTableUtil
