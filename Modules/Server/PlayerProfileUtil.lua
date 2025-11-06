-- Modules/Server/PlayerProfileUtil.lua
-- Lightweight player profile manager with optional DataStore persistence and cross-server locks

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
assert(RunService:IsServer(), "PlayerProfileUtil must be required on the server")

local DataStoreUtil = require(script.Parent.DataStoreUtil)
local DistributedLockUtil = require(script.Parent.DistributedLockUtil)
local Signal = require(ReplicatedStorage:WaitForChild("Modules").Signal)

local PlayerProfileUtil = {}
PlayerProfileUtil.__index = PlayerProfileUtil

-- new(storeName: string, template: table, opts?: { lockTtl?: number, saveOnLeave?: boolean, dryRun?: boolean, keyFn?: (Player)->string })
function PlayerProfileUtil.new(storeName, template, opts)
    opts = opts or {}
    local self = setmetatable({}, PlayerProfileUtil)
    self._storeName = storeName
    self._template = template or {}
    self._lockTtl = opts.lockTtl or 30
    self._saveOnLeave = opts.saveOnLeave ~= false
    self._dryRun = opts.dryRun or false
    self._keyFn = opts.keyFn or function(p) return tostring(p.UserId) end
    self._profiles = {} -- [userId] = { data=table, token=string?, key=string, loadedAt:number }
    self._loaded = Signal.new()
    self._saving = Signal.new()
    self._released = Signal.new()
    self._running = false
    return self
end

function PlayerProfileUtil:onLoaded(cb) return self._loaded:Connect(cb) end
function PlayerProfileUtil:onSaving(cb) return self._saving:Connect(cb) end
function PlayerProfileUtil:onReleased(cb) return self._released:Connect(cb) end

function PlayerProfileUtil:_getStore()
    if self._dryRun or not self._storeName then return nil end
    return DataStoreUtil.getStore(self._storeName)
end

function PlayerProfileUtil:get(player)
    local rec = self._profiles[player.UserId]
    return rec and rec.data or nil
end

function PlayerProfileUtil:save(player)
    local rec = self._profiles[player.UserId]
    if not rec then return false, "no profile" end
    self._saving:Fire(player, rec.data)
    if self._dryRun then return true end
    local store = self:_getStore()
    if not store then return false, "no store" end
    local ok, err = DataStoreUtil.set(store, rec.key, rec.data, { retries = 2, backoff = 1, budget = true })
    return ok, err
end

function PlayerProfileUtil:_acquire(player)
    local key = self._keyFn(player)
    local lockKey = "profile:" .. key
    local token
    if not self._dryRun then
        local ok, tOrErr = DistributedLockUtil.acquire(lockKey, self._lockTtl)
        if not ok then
            warn("PlayerProfileUtil: lock acquire failed for", key, tOrErr)
        else
            token = tOrErr
        end
    end
    local data
    if self._dryRun then
        -- clone template shallowly
        data = {}
        for k, v in pairs(self._template) do data[k] = v end
    else
        local store = self:_getStore()
        if store then
            local ok, value = DataStoreUtil.get(store, key, { retries = 2, backoff = 1, budget = true })
            if ok and value ~= nil then
                data = value
            else
                -- Initialize with template
                data = {}
                for k, v in pairs(self._template) do data[k] = v end
                DataStoreUtil.set(store, key, data, { retries = 2, backoff = 1, budget = true })
            end
        else
            data = {}
            for k, v in pairs(self._template) do data[k] = v end
        end
    end
    self._profiles[player.UserId] = { data = data, token = token, key = self._keyFn(player), loadedAt = os.time() }
    self._loaded:Fire(player, data)
end

function PlayerProfileUtil:_release(player)
    local rec = self._profiles[player.UserId]
    if not rec then return end
    if self._saveOnLeave then self:save(player) end
    self._released:Fire(player, rec.data)
    if not self._dryRun and rec.token then
        DistributedLockUtil.release("profile:" .. rec.key, rec.token)
    end
    self._profiles[player.UserId] = nil
end

function PlayerProfileUtil:bind()
    if self._running then return function() end end
    self._running = true
    local addedConn = Players.PlayerAdded:Connect(function(p)
        self:_acquire(p)
    end)
    local removingConn = Players.PlayerRemoving:Connect(function(p)
        self:_release(p)
    end)
    -- Acquire for already present players (e.g., when running in a live server)
    for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(function() self:_acquire(p) end)
    end
    return function()
        if addedConn.Connected then addedConn:Disconnect() end
        if removingConn.Connected then removingConn:Disconnect() end
        self._running = false
    end
end

function PlayerProfileUtil:destroy()
    self._running = false
    self._loaded:Destroy(); self._saving:Destroy(); self._released:Destroy()
    -- Release all
    for _, p in ipairs(Players:GetPlayers()) do
        self:_release(p)
    end
    self._profiles = {}
end

return PlayerProfileUtil
