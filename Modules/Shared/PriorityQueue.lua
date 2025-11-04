-- Modules/Shared/PriorityQueue.lua
-- Binary heap priority queue (min-heap by default)

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

local function defaultLess(a, b) return a < b end

function PriorityQueue.new(lessFn)
	local self = setmetatable({}, PriorityQueue)
	self._data = {}
	self._len = 0
	self._less = lessFn or defaultLess
	return self
end

local function swap(t, i, j)
	t[i], t[j] = t[j], t[i]
end

local function siftUp(self, idx)
	local data, less = self._data, self._less
	while idx > 1 do
		local parent = math.floor(idx / 2)
		if not less(data[idx], data[parent]) then break end
		swap(data, idx, parent)
		idx = parent
	end
end

local function siftDown(self, idx)
	local data, len, less = self._data, self._len, self._less
	while true do
		local left = idx * 2
		local right = left + 1
		local smallest = idx
		if left <= len and less(data[left], data[smallest]) then smallest = left end
		if right <= len and less(data[right], data[smallest]) then smallest = right end
		if smallest == idx then break end
		swap(data, idx, smallest)
		idx = smallest
	end
end

function PriorityQueue:push(v)
	self._len += 1
	self._data[self._len] = v
	siftUp(self, self._len)
end

function PriorityQueue:pop()
	if self._len == 0 then return nil end
	local root = self._data[1]
	self._data[1] = self._data[self._len]
	self._data[self._len] = nil
	self._len -= 1
	if self._len > 0 then siftDown(self, 1) end
	return root
end

function PriorityQueue:peek()
	return self._data[1]
end

function PriorityQueue:len()
	return self._len
end

return PriorityQueue
