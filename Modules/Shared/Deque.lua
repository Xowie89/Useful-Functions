-- Modules/Shared/Deque.lua
-- Double-ended queue with O(1) push/pop from both ends

local Deque = {}
Deque.__index = Deque

function Deque.new()
	local self = setmetatable({}, Deque)
	self._data = {}
	self._head = 0
	self._tail = -1
	return self
end

function Deque:pushLeft(v)
	self._head -= 1
	self._data[self._head] = v
end

function Deque:pushRight(v)
	self._tail += 1
	self._data[self._tail] = v
end

function Deque:popLeft()
	if self._head > self._tail then return nil end
	local v = self._data[self._head]
	self._data[self._head] = nil
	self._head += 1
	return v
end

function Deque:popRight()
	if self._head > self._tail then return nil end
	local v = self._data[self._tail]
	self._data[self._tail] = nil
	self._tail -= 1
	return v
end

function Deque:peekLeft() return (self._head <= self._tail) and self._data[self._head] or nil end
function Deque:peekRight() return (self._head <= self._tail) and self._data[self._tail] or nil end

function Deque:clear()
	self._data = {}
	self._head = 0
	self._tail = -1
end

function Deque:len()
	return self._tail - self._head + 1
end

return Deque
