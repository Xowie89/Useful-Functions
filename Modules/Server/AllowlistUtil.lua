-- Modules/Server/AllowlistUtil.lua
-- Control join access via open/allowlist/denylist modes; optional persistence; auto-kick binder

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "AllowlistUtil must be required on the server")

local DataStoreUtil = require(script.Parent.DataStoreUtil)

local AllowlistUtil = {}
AllowlistUtil.__index = AllowlistUtil

-- new(opts?: { mode?: "open"|"allowlist"|"denylist", kickMessage?: string, storeName?: string, scope?: string, dryRun?: boolean })
function AllowlistUtil.new(opts)
    opts = opts or {}
    local self = setmetatable({}, AllowlistUtil)
    self._mode = opts.mode or "open"
    self._kickMessage = opts.kickMessage or "Access restricted."
    self._dryRun = opts.dryRun or false
    self._storeName = opts.storeName -- optional persistence
    self._scope = opts.scope
    self._allow = {} -- set of userId -> true
    self._deny = {} -- set of userId -> true
    self._running = false
    if self._storeName and not self._dryRun then
        self:_load()
    end
    return self
end

function AllowlistUtil:_getStore()
    if not self._storeName or self._dryRun then return nil end
    return DataStoreUtil.getStore(self._storeName, self._scope)
end

function AllowlistUtil:_load()
    local store = self:_getStore(); if not store then return end
    local ok1, mode = DataStoreUtil.get(store, "_mode")
    if ok1 and mode then self._mode = mode end
    local ok2, allow = DataStoreUtil.get(store, "_allow")
    if ok2 and type(allow) == "table" then for _, id in ipairs(allow) do self._allow[id] = true end end
    local ok3, deny = DataStoreUtil.get(store, "_deny")
    if ok3 and type(deny) == "table" then for _, id in ipairs(deny) do self._deny[id] = true end end
end

function AllowlistUtil:_persist()
    local store = self:_getStore(); if not store then return end
    DataStoreUtil.set(store, "_mode", self._mode)
    local allowList = {}; for id, v in pairs(self._allow) do if v then table.insert(allowList, id) end end
    local denyList = {}; for id, v in pairs(self._deny) do if v then table.insert(denyList, id) end end
    DataStoreUtil.set(store, "_allow", allowList)
    DataStoreUtil.set(store, "_deny", denyList)
end

function AllowlistUtil:setMode(mode)
    assert(mode == "open" or mode == "allowlist" or mode == "denylist", "invalid mode")
    self._mode = mode
    self:_persist()
end

function AllowlistUtil:add(userId)
    self._allow[userId] = true
    self:_persist()
end

function AllowlistUtil:remove(userId)
    self._allow[userId] = nil
    self:_persist()
end

function AllowlistUtil:deny(userId)
    self._deny[userId] = true
    self:_persist()
end

function AllowlistUtil:undeny(userId)
    self._deny[userId] = nil
    self:_persist()
end

function AllowlistUtil:isAllowed(player)
    local uid = player.UserId
    if self._mode == "open" then
        return self._deny[uid] ~= true
    elseif self._mode == "allowlist" then
        return self._allow[uid] == true
    elseif self._mode == "denylist" then
        return self._deny[uid] ~= true
    end
    return true
end

function AllowlistUtil:bind()
    if self._running then return function() end end
    self._running = true
    local addedConn = Players.PlayerAdded:Connect(function(p)
        if not self:isAllowed(p) then
            if not self._dryRun then
                p:Kick(self._kickMessage)
            end
        end
    end)
    return function()
        if addedConn.Connected then addedConn:Disconnect() end
        self._running = false
    end
end

return AllowlistUtil
