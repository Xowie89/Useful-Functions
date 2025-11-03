-- AllModules.client.lua
-- Smoke tests for shared + client-only modules via UsefulFunctionsClient bundle

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "Run this script on the client")

local Modules = require(ReplicatedStorage:WaitForChild("UsefulFunctionsClient"))

local total, passed, failed = 0, 0, 0
local function runTest(name, fn)
	total += 1
	local ok, err = pcall(fn)
	if ok then
		passed += 1
		print("[PASS]", name)
	else
		failed += 1
		warn("[FAIL]", name, err)
	end
end

-- Shared module tests (lightweight)
runTest("Signal", function()
	local called
	local s = Modules.Signal.new()
	s:Once(function(v) called = v end)
	s:Fire(123)
	task.wait()
	assert(called == 123, "Signal did not deliver value")
	s:Destroy()
end)

runTest("Maid", function()
	local flag = false
	local m = Modules.Maid.new()
	m:GiveTask(function() flag = true end)
	m:Cleanup()
	assert(flag == true, "Maid cleanup didn't run function task")
end)

runTest("Debounce", function()
	local seen
	local f = Modules.Debounce.debounce(function(v) seen = v end, 0.01)
	f(7)
	task.wait(0.05)
	assert(seen == 7, "Debounce didn't call")
end)

runTest("Timer", function()
	local seen
	Modules.Timer.setTimeout(function() seen = true end, 0.01)
	task.wait(0.05)
	assert(seen == true, "Timeout didn't fire")
end)

runTest("TweenUtil", function()
	Modules.TweenUtil.tween(0, 1, TweenInfo.new(0), function(_) end)
	local gui = Instance.new("Frame")
	gui.Size = UDim2.fromScale(0,0)
	Modules.TweenUtil.tween(gui, { Size = UDim2.fromScale(1,1) }, TweenInfo.new(0))
end)

runTest("InstanceUtil", function()
	local f = Modules.InstanceUtil.create("Folder", { Name = "_TestFolder", Parent = workspace })
	assert(f and f.Name == "_TestFolder")
	f:Destroy()
end)

runTest("TableUtil", function()
	assert(Modules.TableUtil.shallowEqual({a=1},{a=1}))
end)

runTest("StringUtil", function()
	assert(Modules.StringUtil.trim("  hi  ") == "hi")
end)

runTest("MathUtil", function()
	assert(math.abs(Modules.MathUtil.remap(5,0,10,0,1) - 0.5) < 1e-6)
end)

runTest("ColorUtil", function()
	local c = Modules.ColorUtil.fromHex("#FFAA00")
	assert(typeof(c) == "Color3")
end)

runTest("CollectionUtil", function()
	local p = Instance.new("Part")
	Modules.CollectionUtil.addTag(p, "_TmpTag")
	Modules.CollectionUtil.removeTag(p, "_TmpTag")
end)

runTest("TimeUtil", function()
	local s = Modules.TimeUtil.formatDuration(61)
	assert(type(s) == "string")
end)

runTest("PromiseUtil", function()
	local ok = false
	Modules.PromiseUtil.resolve(5):andThen(function(v) ok = (v == 5) end)
	task.wait()
	assert(ok, "PromiseUtil.resolve failed")
end)

runTest("CFrameUtil", function()
	local cf = Modules.CFrameUtil.lookAt(Vector3.new(0,5,0), Vector3.new(0,0,0))
	assert(typeof(cf) == "CFrame")
	Modules.CFrameUtil.clampYaw(cf, -math.pi/2, math.pi/2)
end)

runTest("RandomUtil", function()
	local RNG = Modules.RandomUtil.new(123)
	local x = RNG:sample({1,2,3}, 1)
	assert(#x == 1)
end)

runTest("RateLimiter", function()
	local rl = Modules.RateLimiter.new(2, 100)
	local a = rl:allow("k")
	local b = rl:allow("k")
	local c = rl:allow("k")
	assert(a and b and not c)
end)

runTest("CooldownUtil", function()
	local cd = Modules.CooldownUtil.new(0.01)
	assert(cd:use("x"))
	assert(not cd:use("x"))
	task.wait(0.02)
	assert(cd:use("x"))
end)

runTest("StateMachine", function()
	local fsm = Modules.StateMachine.new("Idle")
	fsm:addState("Idle", {})
	fsm:addState("Run", {})
	fsm:transition("Run")
end)

-- Client-only
runTest("CameraUtil (client)", function()
	Modules.CameraUtil.setSubject(nil)
	Modules.CameraUtil.tweenTo(CFrame.new(), TweenInfo.new(0))
end)

runTest("ClientRateLimiter (client)", function()
	local rl = Modules.ClientRateLimiter.new(3, 1)
	local ok1 = rl:allow("click")
	assert(type(ok1) == "boolean")
end)

runTest("NotificationUtil (client)", function()
	Modules.NotificationUtil.show("Test Toast", { duration = 0.1 })
end)

runTest("NotificationQueue (client)", function()
	local nq = Modules.NotificationQueue.new({ maxVisible = 2 })
	nq:enqueue("Hello")
end)

runTest("ProgressBar (client)", function()
	local bar = Modules.ProgressBar.create()
	bar:SetProgress(0)
	bar:SetProgress(1)
end)

print(string.format("AllModules.client: %d passed, %d failed (total %d)", passed, failed, total))
if failed > 0 then
	warn("Some client tests failed.")
end
