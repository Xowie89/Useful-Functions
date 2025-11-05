-- DistributedLockUtil.lua
-- Simple distributed locking using MemoryStore SortedMap

local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local HttpService = game:GetService("HttpService")
assert(RunService:IsServer(), "DistributedLockUtil must be used on the server")

local MAP_NAME = "UF_DistributedLocks"
local map = MemoryStoreService:GetSortedMap(MAP_NAME)

export type LockRecord = { token: string, expiresAt: number }

local DEFAULT_TTL = 30 -- seconds
local RETRIES = 3

local function now()
    return os.time()
end

local function genToken()
    return HttpService:GenerateGUID(false)
end

local M = {}

-- Try to acquire a lock for key with ttlSeconds. Returns ok, tokenOrErr
function M.acquire(key: string, ttlSeconds: number?): (boolean, string)
    assert(type(key) == "string" and #key > 0, "key required")
    local ttl = ttlSeconds or DEFAULT_TTL
    local token = genToken()
    local attempts = 0
    while attempts <= RETRIES do
        attempts += 1
        local ok, res = pcall(function()
            return map:UpdateAsync(key, function(old: LockRecord?)
                local t = now()
                if old == nil or (old.expiresAt or 0) <= t then
                    return { token = token, expiresAt = t + ttl }
                else
                    return old -- keep existing
                end
            end, ttl)
        end)
        if not ok then
            if attempts > RETRIES then return false, tostring(res) end
            task.wait(0.1 * attempts)
        else
            local record = res :: LockRecord
            if record and record.token == token then
                return true, token
            end
            return false, "locked"
        end
    end
    return false, "locked"
end

-- Renew a lock if we still own it. Returns ok, err?
function M.renew(key: string, token: string, ttlSeconds: number?): (boolean, string?)
    local ttl = ttlSeconds or DEFAULT_TTL
    local ok, res = pcall(function()
        return map:UpdateAsync(key, function(old: LockRecord?)
            local t = now()
            if old and old.token == token and (old.expiresAt or 0) > t then
                return { token = token, expiresAt = t + ttl }
            end
            return old
        end, ttl)
    end)
    if not ok then return false, tostring(res) end
    local record = res :: LockRecord
    if record and record.token == token then return true end
    return false, "not-owner-or-expired"
end

-- Release a lock if we own it. Returns ok, err?
function M.release(key: string, token: string): (boolean, string?)
    local ok, res = pcall(function()
        return map:UpdateAsync(key, function(old: LockRecord?)
            if old and old.token == token then
                return nil -- delete
            end
            return old
        end, 1)
    end)
    if not ok then return false, tostring(res) end
    local record = res :: LockRecord?
    if record == nil then return true end
    if record and record.token ~= token then return false, "not-owner" end
    return true
end

return M
