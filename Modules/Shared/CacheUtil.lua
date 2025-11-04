-- Modules/Shared/CacheUtil.lua
-- Tiny TTL cache with get/set and getOrCompute

local CacheUtil = {}
CacheUtil.__index = CacheUtil

function CacheUtil.new(defaultTtlSeconds: number?, maxSize: number?)
	local self = setmetatable({}, CacheUtil)
	self.ttl = tonumber(defaultTtlSeconds) or 60
	self.maxSize = tonumber(maxSize) or 0 -- 0 = unlimited
	self.store = {}
	self.order = {}
	return self
end

local function now()
	return os.clock()
end

local function evict(self)
	if self.maxSize > 0 and #self.order > self.maxSize then
		local oldest = table.remove(self.order, 1)
		if oldest then self.store[oldest] = nil end
	end
end

function CacheUtil:set(key: string, value: any, ttlSeconds: number?)
	local expiry = now() + (tonumber(ttlSeconds) or self.ttl)
	local existed = self.store[key] ~= nil
	self.store[key] = { value = value, expiry = expiry }
	if not existed then table.insert(self.order, key) end
	evict(self)
	return value
end

function CacheUtil:get(key: string)
	local entry = self.store[key]
	if not entry then return nil end
	if entry.expiry <= now() then
		self.store[key] = nil
		for i, k in ipairs(self.order) do
			if k == key then table.remove(self.order, i) break end
		end
		return nil
	end
	return entry.value
end

function CacheUtil:getOrCompute(key: string, producer: (any) -> any, ttlSeconds: number?)
	local v = self:get(key)
	if v ~= nil then return v end
	v = producer()
	self:set(key, v, ttlSeconds)
	return v
end

function CacheUtil:delete(key: string)
	self.store[key] = nil
	for i, k in ipairs(self.order) do
		if k == key then table.remove(self.order, i) break end
	end
end

function CacheUtil:clear()
	self.store = {}
	self.order = {}
end

function CacheUtil:size()
	return #self.order
end

return CacheUtil
