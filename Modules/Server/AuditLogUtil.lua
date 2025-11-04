-- AuditLogUtil.lua
-- Buffered audit/event logging using WebhookUtil or HttpUtil

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "AuditLogUtil must be used on the server")

local WebhookUtil = require(script.Parent.WebhookUtil)

local Logger = {}
Logger.__index = Logger

function Logger.new(url, opts)
	local self = setmetatable({}, Logger)
	self.url = url
	self.batchSize = (opts and opts.batchSize) or 10
	self.flushInterval = (opts and opts.flushInterval) or 5
	self.queue = {}
	self._running = false
	return self
end

function Logger:setDestination(url)
	self.url = url
end

function Logger:log(eventName, fields)
	table.insert(self.queue, {
		ts = os.time(),
		event = eventName,
		fields = fields or {},
	})
end

function Logger:_flushOnce()
	if not self.url or #self.queue == 0 then return end
	local batch = {}
	for i = 1, math.min(#self.queue, self.batchSize) do
		batch[i] = self.queue[i]
	end
	-- remove used entries
	for i = 1, #batch do table.remove(self.queue, 1) end
	local ok, res = WebhookUtil.postJson(self.url, { entries = batch })
	if not ok then warn("AuditLogUtil flush failed:", res) end
end

function Logger:start()
	if self._running then return end
	self._running = true
	task.spawn(function()
		while self._running do
			self:_flushOnce()
			task.wait(self.flushInterval)
		end
	end)
end

function Logger:stop()
	self._running = false
end

local M = {}

function M.new(url, opts)
	return Logger.new(url, opts)
end

return M
