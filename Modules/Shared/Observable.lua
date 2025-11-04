-- Modules/Shared/Observable.lua
-- Simple value holder with a Changed signal

local Signal = require(script.Parent.Signal)

local Observable = {}
Observable.__index = Observable

function Observable.new(initial: any)
	local self = setmetatable({}, Observable)
	self._value = initial
	self.Changed = Signal.new()
	return self
end

function Observable:get()
	return self._value
end

function Observable:set(v)
	if self._value ~= v then
		self._value = v
		self.Changed:Fire(v)
	end
end

function Observable:Destroy()
	if self.Changed then
		self.Changed:Destroy()
		self.Changed = nil
	end
end

return Observable
