-- StateMachine.lua
-- Simple finite state machine with enter/exit hooks and a state changed signal
-- API:
--   local fsm = StateMachine.new(initialState)
--   fsm:addState(name, { onEnter = function(prev, data) end, onExit = function(next, data) end })
--   fsm:can(target) -> boolean
--   fsm:transition(target, data?) -> boolean
--   fsm.stateChanged (Signal) -> :Connect(fn(current, previous))

local Signal = require(script.Parent.Signal)

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(initial: string)
	local self = setmetatable({}, StateMachine)
	self._states = {}
	self.current = initial
	self.stateChanged = Signal.new()
	return self
end

function StateMachine:addState(name: string, def: { onEnter: (prev:string?, data:any?) -> (), onExit: (next:string?, data:any?) -> () }?)
	self._states[name] = def or {}
	return self
end

function StateMachine:can(target: string)
	return target ~= nil and self._states[target] ~= nil and target ~= self.current
end

function StateMachine:transition(target: string, data: any?)
	if not self:can(target) then return false end
	local prev = self.current
	local prevDef = self._states[prev]
	local nextDef = self._states[target]
	if prevDef and prevDef.onExit then
		local ok, err = pcall(prevDef.onExit, target, data)
		if not ok then warn("StateMachine onExit error:", err) end
	end
	self.current = target
	if nextDef and nextDef.onEnter then
		local ok, err = pcall(nextDef.onEnter, prev, data)
		if not ok then warn("StateMachine onEnter error:", err) end
	end
	self.stateChanged:Fire(self.current, prev)
	return true
end

function StateMachine:destroy()
	self.stateChanged:Destroy()
	self._states = {}
end

return StateMachine