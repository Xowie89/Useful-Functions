-- Modules/Shared/LRUCache.lua
-- Size-bounded LRU cache with optional per-key TTL

local LRUCache = {}
LRUCache.__index = LRUCache

-- Doubly-linked list node
local function newNode(key, value, expiry)
	return { key = key, value = value, expiry = expiry, prev = nil, next = nil }
end

local function now()
	return os.clock()
end

function LRUCache.new(capacity: number)
	assert(capacity and capacity > 0, "LRUCache.new requires a positive capacity")
	local self = setmetatable({}, LRUCache)
	self.capacity = math.floor(capacity)
	self.size = 0
	self.map = {}
	-- Dummy head/tail
	self.head = { next = nil }
	self.tail = { prev = nil }
	self.head.next = self.tail
	self.tail.prev = self.head
	return self
end

local function removeNode(self, node)
	node.prev.next = node.next
	node.next.prev = node.prev
	node.prev, node.next = nil, nil
end

local function addFront(self, node)
	node.next = self.head.next
	node.prev = self.head
	self.head.next.prev = node
	self.head.next = node
end

local function evictTail(self)
	local node = self.tail.prev
	if node == self.head then return end
	removeNode(self, node)
	self.map[node.key] = nil
	self.size -= 1
end

local function isExpired(node)
	return node.expiry ~= nil and node.expiry <= now()
end

function LRUCache:set(key, value, ttlSeconds: number?)
	local node = self.map[key]
	local exp = ttlSeconds and (now() + ttlSeconds) or nil
	if node then
		node.value = value
		node.expiry = exp
		removeNode(self, node)
		addFront(self, node)
		return value
	end
	node = newNode(key, value, exp)
	self.map[key] = node
	addFront(self, node)
	self.size += 1
	if self.size > self.capacity then
		evictTail(self)
	end
	return value
end

function LRUCache:get(key)
	local node = self.map[key]
	if not node then return nil end
	if isExpired(node) then
		removeNode(self, node)
		self.map[key] = nil
		self.size -= 1
		return nil
	end
	removeNode(self, node)
	addFront(self, node)
	return node.value
end

function LRUCache:delete(key)
	local node = self.map[key]
	if not node then return end
	removeNode(self, node)
	self.map[key] = nil
	self.size -= 1
end

function LRUCache:clear()
	self.map = {}
	self.size = 0
	self.head.next = self.tail
	self.tail.prev = self.head
end

function LRUCache:len()
	return self.size
end

return LRUCache
