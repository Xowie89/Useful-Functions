-- UsefulFunctionsClient.lua
-- Top-level re-export for client-only aggregator (ReplicatedStorage)

local ModulesFolder = script.Parent:WaitForChild("Modules")
local ClientFolder = ModulesFolder:WaitForChild("Client")
local Aggregator = ClientFolder:WaitForChild("init")
return require(Aggregator)
