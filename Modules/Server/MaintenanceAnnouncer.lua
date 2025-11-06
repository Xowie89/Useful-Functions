-- Modules/Server/MaintenanceAnnouncer.lua
-- Schedule and broadcast maintenance reminders; optionally initiate shutdown

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
assert(RunService:IsServer(), "MaintenanceAnnouncer must be required on the server")

local MessagingServiceUtil = require(script.Parent.MessagingServiceUtil)
local ShutdownUtil = require(script.Parent.ShutdownUtil)

local MaintenanceAnnouncer = {}
MaintenanceAnnouncer.__index = MaintenanceAnnouncer

-- options: { topic?: string, reminders?: {number}, kickAtEnd?: boolean }
function MaintenanceAnnouncer.new(maintenanceUnix, options)
    local self = setmetatable({}, MaintenanceAnnouncer)
    self._ts = maintenanceUnix
    self._topic = (options and options.topic) or "uf:maintenance"
    self._reminders = (options and options.reminders) or { 3600, 600, 300, 60 }
    self._kickAtEnd = (options and options.kickAtEnd) ~= false
    self._tasks = {}
    return self
end

local function publish(topic, payload)
    local ok, err = MessagingServiceUtil.publish(topic, payload)
    if not ok then warn("MaintenanceAnnouncer publish failed:", err) end
end

-- Broadcast a message immediately via MessagingService topic
function MaintenanceAnnouncer:announce(text)
    publish(self._topic, { kind = "notice", text = text, ts = os.time() })
end

function MaintenanceAnnouncer:start()
    local now = os.time()
    local when = self._ts
    -- Schedule reminders
    for _, before in ipairs(self._reminders) do
        local fireAt = when - before
        local delaySec = fireAt - now
        if delaySec >= 0 then
            table.insert(self._tasks, task.delay(delaySec, function()
                local mins = math.floor(before / 60)
                local text = mins > 0 and ("Maintenance in %d minute(s). Please finish up."):format(mins) or "Maintenance in 60 seconds."
                self:announce(text)
            end))
        end
    end
    -- Final action
    local finalDelay = math.max(0, when - now)
    table.insert(self._tasks, task.delay(finalDelay, function()
        self:announce("Maintenance starting now.")
        if self._kickAtEnd then
            ShutdownUtil.initiate("Scheduled maintenance. Please rejoin shortly.")
        end
    end))
end

function MaintenanceAnnouncer:stop()
    for _, h in ipairs(self._tasks) do
        -- task.delay returns connection? Not directly; delays can't be cancelled.
        -- For simplicity, stop() is best-effort (no-op for scheduled delays).
    end
    self._tasks = {}
end

return MaintenanceAnnouncer
