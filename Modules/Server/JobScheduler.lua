-- JobScheduler.lua
-- Minimal MemoryStore-backed job queue + worker loop

local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
assert(RunService:IsServer(), "JobScheduler must be used on the server")

local DEFAULT_VISIBILITY = 30
local DEFAULT_POLL = 1

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new(name, opts)
	assert(type(name) == "string" and #name > 0, "queue name required")
	opts = opts or {}
	local self = setmetatable({}, Scheduler)
	self.queue = MemoryStoreService:GetQueue(name)
	self.name = name
	self.visibility = opts.visibility or DEFAULT_VISIBILITY
	self.poll = opts.poll or DEFAULT_POLL
	self._running = false
	self._thread = nil
	return self
end

function Scheduler:enqueue(payload, ttl)
	local ok, err = pcall(function()
		self.queue:AddAsync(payload, ttl or 60)
	end)
	return ok, err
end

function Scheduler:startWorker(handler)
	assert(type(handler) == "function", "handler(payload, entry) required")
	if self._running then return end
	self._running = true
	self._thread = task.spawn(function()
		while self._running do
			local ok, entries = pcall(function()
				return self.queue:ReadAsync(1, false, self.visibility)
			end)
			if ok and entries and #entries > 0 then
				local entry = entries[1]
				local okH, err = pcall(handler, entry.Value, entry)
				if not okH then warn("Job handler error:", err) end
				pcall(function()
					self.queue:RemoveAsync(entry.Id)
				end)
			else
				task.wait(self.poll)
			end
		end
	end)
end

function Scheduler:stopWorker()
	self._running = false
end

local M = {}

function M.new(name, opts)
	return Scheduler.new(name, opts)
end

return M
