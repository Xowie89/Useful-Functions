-- Modules/Server/PlayerBanEnforcer.lua
-- Automatically kicks banned players on join using BanUtil

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
assert(RunService:IsServer(), "PlayerBanEnforcer must be required on the server")

local BanUtil = require(script.Parent.BanUtil)

local Enforcer = {}
Enforcer.__index = Enforcer

function Enforcer.new()
    local self = setmetatable({}, Enforcer)
    self._bound = false
    self._conns = {}
    return self
end

local function handlePlayer(player)
    local shouldKick, msg = BanUtil.shouldKick(player)
    if shouldKick then
        pcall(function()
            player:Kick(msg or "You are banned from this experience.")
        end)
    end
end

function Enforcer:bind()
    if self._bound then return function() end end
    self._bound = true
    -- Existing players
    for _, plr in ipairs(Players:GetPlayers()) do
        handlePlayer(plr)
    end
    -- Future joins
    local added = Players.PlayerAdded:Connect(handlePlayer)
    table.insert(self._conns, added)
    return function()
        for _, c in ipairs(self._conns) do
            if c.Connected then c:Disconnect() end
        end
        self._conns = {}
        self._bound = false
    end
end

return Enforcer
