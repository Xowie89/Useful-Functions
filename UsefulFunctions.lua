-- UsefulFunctions.lua
-- Top-level re-export of everything in Modules/init for a simple require path
-- Place this ModuleScript alongside the `Modules` folder (e.g., in ReplicatedStorage)

local ModulesFolder = script.Parent:WaitForChild("Modules")
local Aggregator = ModulesFolder:WaitForChild("init")
return require(Aggregator)