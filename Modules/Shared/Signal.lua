-- Signal.lua
-- Lightweight event signal using BindableEvent
-- API: Signal.new(), :Connect(fn), :Once(fn), :Fire(...), :Wait(), :Destroy()

local Signal = {}
Signal.__index = Signal

export type Connection = RBXScriptConnection
export type Signal = {
	Connect: (self: Signal, fn: (...any) -> ()) -> Connection,
	Once: (self: Signal, fn: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Wait: (self: Signal) -> ...any,
	Destroy: (self: Signal) -> (),
}

function Signal.new(): Signal
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	self._connections = {} :: {Connection}
	return self
end

function Signal:Connect(fn: (...any) -> ()): Connection
	assert(typeof(self) == "table" and self._bindable, "Signal:Connect called on non-signal")
	assert(type(fn) == "function", "Connect expects a function")
	local connection = self._bindable.Event:Connect(fn)
	table.insert(self._connections, connection)
	return connection
end

function Signal:Once(fn: (...any) -> ()): Connection
	assert(type(fn) == "function", "Once expects a function")
	local connection: Connection
	connection = self:Connect(function(...)
		if connection and connection.Connected then
			connection:Disconnect()
		end
		fn(...)
	end)
	return connection
end

function Signal:Fire(...: any)
	self._bindable:Fire(...)
end

function Signal:Wait(): ...any
	return self._bindable.Event:Wait()
end

function Signal:Destroy()
	for i = #self._connections, 1, -1 do
		local c = self._connections[i]
		if c and c.Connected then c:Disconnect() end
		self._connections[i] = nil
	end
	self._bindable:Destroy()
	self._bindable = nil
end

return Signal