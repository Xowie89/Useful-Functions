-- Modules/Shared/Memoize.lua
-- Generic memoization with optional TTL and size bound via embedded LRUCache

local HashUtil = require(script.Parent.HashUtil)
local LRUCache = require(script.Parent.LRUCache)

local Memoize = {}

-- Wraps a function and memoizes results based on args.
-- options: { ttl: number?, capacity: number?, keyFn: (argsTable)-> any }
function Memoize.wrap(fn, options)
	assert(type(fn) == "function", "Memoize.wrap requires a function")
	options = options or {}
	local capacity = options.capacity or 512
	local ttl = options.ttl
	local keyFn = options.keyFn or function(args)
		return HashUtil.stableHash(args)
	end
	local cache = LRUCache.new(capacity)

	return function(...)
		local args = table.pack(...)
		local key = keyFn(args)
		local value = cache:get(key)
		if value ~= nil then return value end
		value = fn(...)
		cache:set(key, value, ttl)
		return value
	end, cache
end

return Memoize
