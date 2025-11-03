-- Maid.lua
-- Simple resource manager for cleanup of connections, instances, and functions
-- API: Maid.new(), :GiveTask(task) -> token, :Cleanup(), :Destroy(), :DoCleaning()

local Maid = {}
Maid.__index = Maid

export type Maid = {
	GiveTask: (self: Maid, task: any) -> any,
	Cleanup: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
	DoCleaning: (self: Maid) -> (),
}

local function cleanupTask(task: any)
	local taskType = typeof(task)
	if taskType == "RBXScriptConnection" then
		if task.Connected then task:Disconnect() end
	elseif taskType == "Instance" then
		if task.Parent then task.Parent = nil end
		pcall(function() task:Destroy() end)
	elseif taskType == "function" then
		pcall(task)
	elseif taskType == "table" then
		if type(task.Destroy) == "function" then
			pcall(function() task:Destroy() end)
		elseif type(task.Cleanup) == "function" or type(task.DoCleaning) == "function" then
			pcall(function() (task.Cleanup or task.DoCleaning)(task) end)
		end
	end
end

function Maid.new(): Maid
	local self = setmetatable({}, Maid)
	self._tasks = {} :: { [any]: any }
	return self
end

function Maid:GiveTask(task: any)
	local key = task
	if typeof(task) == "RBXScriptConnection" or typeof(task) == "Instance" then
		key = tostring(task) .. "@" .. tostring(#self._tasks + 1)
	end
	self._tasks[key] = task
	return key
end

function Maid:Cleanup()
	for key, task in pairs(self._tasks) do
		cleanupTask(task)
		self._tasks[key] = nil
	end
end

function Maid:DoCleaning()
	self:Cleanup()
end

function Maid:Destroy()
	self:Cleanup()
	setmetatable(self, nil)
end

return Maid