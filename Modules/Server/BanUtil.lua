-- BanUtil.lua
-- Simple ban store using DataStore; supports temporary and permanent bans

local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
assert(RunService:IsServer(), "BanUtil must be used on the server")

local STORE_NAME = "UF_Bans"
local BanStore = DataStoreService:GetDataStore(STORE_NAME)

local function now()
	return os.time()
end

local M = {}

-- Structure: { reason = string?, expiresAt = unixTime? (nil = permanent), by = string? }
function M.ban(userIdOrPlayer, reason, durationSeconds, by)
	local userId = typeof(userIdOrPlayer) == "Instance" and userIdOrPlayer.UserId or userIdOrPlayer
	local expiresAt = durationSeconds and (now() + durationSeconds) or nil
	local data = { reason = reason, expiresAt = expiresAt, by = by }
	local ok, err = pcall(function()
		BanStore:SetAsync("ban:"..tostring(userId), data)
	end)
	return ok, err
end

function M.unban(userIdOrPlayer)
	local userId = typeof(userIdOrPlayer) == "Instance" and userIdOrPlayer.UserId or userIdOrPlayer
	local ok, err = pcall(function()
		BanStore:RemoveAsync("ban:"..tostring(userId))
	end)
	return ok, err
end

function M.getBan(userIdOrPlayer)
	local userId = typeof(userIdOrPlayer) == "Instance" and userIdOrPlayer.UserId or userIdOrPlayer
	local ok, data = pcall(function()
		return BanStore:GetAsync("ban:"..tostring(userId))
	end)
	if not ok then return nil, data end
	return data, nil
end

function M.isBanned(userIdOrPlayer)
	local data = M.getBan(userIdOrPlayer)
	if type(data) == "table" then
		if data.expiresAt and data.expiresAt <= now() then
			return false -- expired
		end
		return true
	end
	return false
end

-- Convenience: returns bool, message if should be kicked
function M.shouldKick(player)
	local data = M.getBan(player)
	if type(data) == "table" then
		if data.expiresAt and data.expiresAt <= now() then
			return false
		end
		local msg = "You are banned"
		if data.reason then msg = msg..": "..tostring(data.reason) end
		if data.expiresAt then
			msg = msg.." (until "..os.date("!%Y-%m-%d %H:%M:%SZ", data.expiresAt)..")"
		end
		return true, msg
	end
	return false
end

return M
