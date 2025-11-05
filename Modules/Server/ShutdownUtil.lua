-- Modules/Server/ShutdownUtil.lua
-- Graceful shutdown coordinator for server

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

assert(RunService:IsServer(), "ShutdownUtil must be required on the server")

local ShutdownUtil = {}
ShutdownUtil.__index = ShutdownUtil

local _state = {
	callbacks = {},
	timeout = 25, -- Roblox grants ~30s in BindToClose; keep a safety margin
	bound = false,
	initiated = false,
}

-- Register a function to be called during shutdown. Returns an unbind function.
function ShutdownUtil.onShutdown(fn)
	assert(type(fn) == "function", "onShutdown expects a function")
	local idx = #_state.callbacks + 1
	_state.callbacks[idx] = fn
	return function()
		_state.callbacks[idx] = nil
	end
end

-- Set the maximum time (seconds) to allow shutdown tasks to run.
function ShutdownUtil.setTimeout(seconds)
	if type(seconds) == "number" and seconds > 0 then
		_state.timeout = seconds
	end
end

-- Attach BindToClose once. All registered callbacks run when the server closes.
function ShutdownUtil.bind()
	if _state.bound then return end
	_state.bound = true
	game:BindToClose(function()
		local start = os.clock()
		-- Run callbacks safely
		for _, cb in pairs(_state.callbacks) do
			local ok, err = pcall(cb)
			if not ok then warn("ShutdownUtil callback error:", err) end
			if os.clock() - start > _state.timeout then
				warn("ShutdownUtil timeout reached; exiting shutdown early")
				break
			end
		end
	end)
end

-- Optionally initiate a shutdown flow early (kick players with a message, etc.).
-- This does NOT actually shut down the server; it simply runs callbacks now and kicks players.
function ShutdownUtil.initiate(reason)
	if _state.initiated then return end
	_state.initiated = true
	-- Run callbacks immediately
	for _, cb in pairs(_state.callbacks) do
		local ok, err = pcall(cb)
		if not ok then warn("ShutdownUtil callback error:", err) end
	end
	-- Notify/kick players (best-effort)
	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(function()
			plr:Kick(reason or "Server is shutting down for maintenance. Please rejoin.")
		end)
	end
end

return ShutdownUtil
