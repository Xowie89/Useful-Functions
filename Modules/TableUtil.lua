-- TableUtil.lua
-- Useful pure Lua table helpers
-- API: copy, assign, mergeDeep, equals, map, filter, find, keys, values

local TableUtil = {}

local function isArray(t: any)
	if type(t) ~= "table" then return false end
	local i = 0
	for _ in pairs(t) do
		i += 1
		if t[i] == nil then return false end
	end
	return true
end

function TableUtil.copy(t: any, deep: boolean?): any
	if type(t) ~= "table" then return t end
	local out = {}
	for k, v in pairs(t) do
		out[TableUtil.copy(k, deep)] = deep and TableUtil.copy(v, true) or v
	end
	return out
end

function TableUtil.assign(target: table, ...): table
	for i = 1, select("#", ...) do
		local src = select(i, ...)
		if type(src) == "table" then
			for k, v in pairs(src) do
				target[k] = v
			end
		end
	end
	return target
end

local function mergeDeepInto(target: table, source: table)
	for k, v in pairs(source) do
		if type(v) == "table" and type(target[k]) == "table" then
			mergeDeepInto(target[k], v)
		else
			target[k] = (type(v) == "table") and TableUtil.copy(v, true) or v
		end
	end
end

function TableUtil.mergeDeep(target: table, ...): table
	for i = 1, select("#", ...) do
		local src = select(i, ...)
		if type(src) == "table" then
			mergeDeepInto(target, src)
		end
	end
	return target
end

local function deepEquals(a: any, b: any, visited: table): boolean
	if a == b then return true end
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	if visited[a] and visited[a] == b then return true end
	visited[a] = b
	local aLen, bLen = 0, 0
	for k in pairs(a) do aLen += 1 end
	for k in pairs(b) do bLen += 1 end
	if aLen ~= bLen then return false end
	for k, v in pairs(a) do
		if not deepEquals(v, b[k], visited) then return false end
	end
	return true
end

function TableUtil.equals(a: any, b: any, deep: boolean?): boolean
	if deep then
		return deepEquals(a, b, {})
	end
	return a == b
end

function TableUtil.map(list: table, fn: (any, number) -> any): table
	local out = {}
	for i, v in ipairs(list) do
		out[i] = fn(v, i)
	end
	return out
end

function TableUtil.filter(list: table, fn: (any, number) -> boolean): table
	local out = {}
	for i, v in ipairs(list) do
		if fn(v, i) then table.insert(out, v) end
	end
	return out
end

function TableUtil.find(list: table, fn: (any, number) -> boolean): any
	for i, v in ipairs(list) do
		if fn(v, i) then return v, i end
	end
	return nil
end

function TableUtil.keys(t: table): table
	local out = {}
	for k in pairs(t) do table.insert(out, k) end
	return out
end

function TableUtil.values(t: table): table
	local out = {}
	for _, v in pairs(t) do table.insert(out, v) end
	return out
end

function TableUtil.isArray(t: any): boolean
	return isArray(t)
end

return TableUtil