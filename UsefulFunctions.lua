-- UsefulFunctions.lua
-- Top-level re-export of Shared bundle shared. Lives in ReplicatedStorage.

local ModulesFolder = script.Parent:WaitForChild("Modules")
local SharedFolder = ModulesFolder:WaitForChild("Shared")
local Aggregator = SharedFolder:WaitForChild("init")
return require(Aggregator)