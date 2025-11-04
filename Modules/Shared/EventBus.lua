-- Modules/Shared/EventBus.lua
-- Lightweight publish/subscribe bus with string topics

local Signal = require(script.Parent.Signal)

local EventBus = {}
EventBus.__index = EventBus

function EventBus.new()
	local self = setmetatable({}, EventBus)
	self._topics = {}
	return self
end

local function ensureTopic(self, topic)
	local s = self._topics[topic]
	if not s then
		s = Signal.new()
		self._topics[topic] = s
	end
	return s
end

function EventBus:subscribe(topic: string, handler)
	local s = ensureTopic(self, topic)
	return s:Connect(handler)
end

function EventBus:publish(topic: string, ...)
	local s = self._topics[topic]
	if s then s:Fire(...) end
end

function EventBus:once(topic: string, handler)
	local s = ensureTopic(self, topic)
	return s:Once(handler)
end

function EventBus:hasSubscribers(topic: string)
	local s = self._topics[topic]
	return s ~= nil and s._count and s._count > 0 or false
end

function EventBus:Destroy()
	for topic, s in pairs(self._topics) do
		if s.Destroy then s:Destroy() end
		self._topics[topic] = nil
	end
end

return EventBus
