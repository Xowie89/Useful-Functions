-- UsefulFunctions.lua
-- Top-level re-export of Shared bundle (client + shared). Lives in ReplicatedStorage.

local ModulesFolder = script.Parent:WaitForChild("Modules")
local SharedFolder = ModulesFolder:WaitForChild("Shared")
local Aggregator = SharedFolder:WaitForChild("init")
return require(Aggregator)