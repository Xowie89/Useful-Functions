-- Modules/Server/CrossServerEvent.lua
-- Simple named cross-server events built on MessagingServiceUtil

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "CrossServerEvent must be required on the server")

local MessagingServiceUtil = require(script.Parent.MessagingServiceUtil)

local CrossServerEvent = {}
CrossServerEvent.__index = CrossServerEvent

function CrossServerEvent.new(prefix)
	local self = setmetatable({}, CrossServerEvent)
	self._prefix = tostring(prefix or "uf:cse")
	self._conns = {}
	return self
end

local function topic(self, eventName)
	return string.format("%s:%s", self._prefix, tostring(eventName))
end

function CrossServerEvent:publish(eventName, data)
	return MessagingServiceUtil.publish(topic(self, eventName), data)
end

function CrossServerEvent:subscribe(eventName, handler)
	local t = topic(self, eventName)
	local conn = MessagingServiceUtil.subscribe(t, function(payload)
		-- Normalize to call user handler with (data, message)
		local ok, err = pcall(handler, payload)
		if not ok then warn("CrossServerEvent handler error:", err) end
	end, { safe = true })
	self._conns[conn] = true
	return {
		Disconnect = function()
			if conn and conn.Disconnect then conn:Disconnect() end
			self._conns[conn] = nil
		end
	}
end

function CrossServerEvent:destroy()
	for conn in pairs(self._conns) do
		pcall(function()
			if conn and conn.Disconnect then conn:Disconnect() end
		end)
		self._conns[conn] = nil
	end
end

return CrossServerEvent
