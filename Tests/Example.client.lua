-- Example.client.lua
-- Optional client test to try UI helpers

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage:WaitForChild("UsefulFunctionsClient"))

Modules.NotificationUtil.show("Hello from NotificationUtil!", { duration = 2.5, stroke = true })

local bar = Modules.ProgressBar.create()
bar:SetText("Loading...")
for i = 0, 100 do
	bar:SetProgress(i/100, 0.01)
	task.wait(0.01)
end
bar:SetText("Done")

-- NotificationQueue demo
local nq = Modules.NotificationQueue.new({ maxVisible = 3 })
nq:enqueue("Queued toast 1")
nq:enqueue("Queued toast 2")
nq:enqueue("Queued toast 3")
nq:enqueue("Queued toast 4 (waits)")

-- ModalUtil demo
Modules.ModalUtil.confirm({
	title = "Try Modal",
	message = "Do you like this library?",
	buttons = { "Yes", "No" },
}):andThen(function(answer)
	nq:enqueue("Answer: "..tostring(answer))
end)

-- ClientRateLimiter demo
local rl = Modules.ClientRateLimiter.new(3, 1) -- 3 tokens, 1/sec refill
for i = 1, 6 do
	local ok, remaining = rl:allow("click")
	nq:enqueue(string.format("click %d allowed=%s (remaining %.1f)", i, tostring(ok), remaining or 0))
	task.wait(0.3)
end
