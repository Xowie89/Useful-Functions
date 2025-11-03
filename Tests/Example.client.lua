-- Example.client.lua
-- Optional client test to try UI helpers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage:WaitForChild("UsefulFunctions"))

Modules.NotificationUtil.show("Hello from NotificationUtil!", { duration = 2.5, stroke = true })

local bar = Modules.ProgressBar.create()
bar:SetText("Loading...")
for i = 0, 100 do
	bar:SetProgress(i/100, 0.01)
	task.wait(0.01)
end
bar:SetText("Done")
