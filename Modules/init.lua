-- Modules/init.lua
-- Compatibility shim: expose the shared bundle when requiring ReplicatedStorage.Modules.init

local SharedInit = script.Parent:WaitForChild("Shared"):WaitForChild("init")
return require(SharedInit)
