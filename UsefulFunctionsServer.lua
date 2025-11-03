-- UsefulFunctionsServer.lua
-- Top-level re-export for server-only aggregator (mapped under ServerScriptService/UsefulFunctions)

local ModulesFolder = script.Parent:WaitForChild("Modules")
local ServerFolder = ModulesFolder:WaitForChild("Server")
local Aggregator = ServerFolder:WaitForChild("init")
return require(Aggregator)
