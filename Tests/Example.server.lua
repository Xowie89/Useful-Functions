-- Example.server.lua
-- Optional: Drop this into ServerScriptService in a test place to try utilities quickly

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Assume you've put the Modules folder in ReplicatedStorage
-- Recommended: require top-level UsefulFunctions ModuleScript next to Modules
local Modules = require(ReplicatedStorage:WaitForChild("UsefulFunctions"))

local Promise = Modules.PromiseUtil
local LeaderstatsUtil = Modules.LeaderstatsUtil
local DataStoreUtil = Modules.DataStoreUtil

-- Create leaderstats for all players and increment coins after 2s
LeaderstatsUtil.bindAutoSetup(Players)
Players.PlayerAdded:Connect(function(player)
	LeaderstatsUtil.addInt(player, "Coins", 0)
	task.delay(2, function()
		LeaderstatsUtil.increment(player, "Coins", 1)
	end)
end)

-- Simple Promise usage
Promise.retry(function()
	if math.random() < 0.3 then error("random fail") end
	return "success"
end, 5, 0.25):andThen(function(msg)
	print("Promise result:", msg)
end):catch(function(err)
	warn("Promise failed:", err)
end)
