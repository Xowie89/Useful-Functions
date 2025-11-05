-- ServerMetricsUtil.lua
-- Gather basic server metrics (uptime, players, job info, memory) and optional publishing helpers

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
assert(RunService:IsServer(), "ServerMetricsUtil must be used on the server")

local startTime = os.time()

local M = {}

local function memoryMB()
    local kb = collectgarbage("count") -- KB
    return math.floor((kb / 1024) * 100 + 0.5) / 100 -- MB with 2 decimals
end

function M.snapshot()
    local players = #Players:GetPlayers()
    return {
        serverTime = os.time(),
        uptimeSec = os.time() - startTime,
        players = players,
        jobId = game.JobId,
        placeId = game.PlaceId,
        private = game.PrivateServerId ~= "",
        memoryMB = memoryMB(),
    }
end

-- Optional: publish snapshot to a MessagingService topic via provided MessagingServiceUtil
function M.publishToTopic(topic: string)
    local ok = false
    local status, err = pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local SharedRoot = ReplicatedStorage:WaitForChild("Modules")
        local Shared = require(SharedRoot.Shared.init)
        local MessagingServiceUtil = require(script.Parent.MessagingServiceUtil)
        ok = select(1, MessagingServiceUtil.publish(topic, M.snapshot())) == true
    end)
    if not status then return false, tostring(err) end
    return ok, ok and nil or "publish-failed"
end

return M
