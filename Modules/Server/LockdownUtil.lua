-- Modules/Server/LockdownUtil.lua
-- Toggle a global lockdown (deny joins) with optional cross-server broadcast

local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "LockdownUtil must be required on the server")

local AllowlistUtil = require(script.Parent.AllowlistUtil)
local MessagingServiceUtil = require(script.Parent.MessagingServiceUtil)

local LockdownUtil = {}
LockdownUtil.__index = LockdownUtil

-- new(opts?: { topic?: string, kickMessage?: string, storeName?: string, scope?: string, dryRun?: boolean })
function LockdownUtil.new(opts)
    opts = opts or {}
    local self = setmetatable({}, LockdownUtil)
    self._topic = opts.topic or "uf:lockdown"
    self._gate = AllowlistUtil.new({ mode = "open", kickMessage = opts.kickMessage, storeName = opts.storeName, scope = opts.scope, dryRun = opts.dryRun })
    return self
end

function LockdownUtil:bind()
    return self._gate:bind()
end

function LockdownUtil:isEnabled()
    -- In allowlist mode with empty allow-list => effectively lockdown for all except explicit allow
    return true and self._gate and self._gate._mode == "allowlist"
end

local function publish(topic, payload)
    local ok, err = MessagingServiceUtil.publish(topic, payload)
    if not ok then warn("LockdownUtil publish failed:", err) end
end

function LockdownUtil:enable(reason)
    self._gate:setMode("allowlist")
    publish(self._topic, { kind = "lockdown", enabled = true, reason = reason, ts = os.time() })
end

function LockdownUtil:disable()
    self._gate:setMode("open")
    publish(self._topic, { kind = "lockdown", enabled = false, ts = os.time() })
end

function LockdownUtil:allow(userId)
    self._gate:add(userId)
end

function LockdownUtil:deny(userId)
    self._gate:deny(userId)
end

function LockdownUtil:isAllowed(player)
    return self._gate:isAllowed(player)
end

return LockdownUtil
