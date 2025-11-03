-- AllModules.server.lua
-- Smoke tests for shared + server-only modules via UsefulFunctionsServer bundle

local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
assert(RunService:IsServer(), "Run this script on the server")

local Modules = require(ServerScriptService:WaitForChild("UsefulFunctions"):WaitForChild("UsefulFunctionsServer"))

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

-- Shared module tests (broad coverage)
runTest("Signal", function()
	local called
	local s = Modules.Signal.new()
	s:Once(function(v) called = v end)
	s:Fire(123)
	task.wait()
	assert(called == 123)
	s:Destroy()
end)

runTest("Maid", function()
	local flag = false
	local m = Modules.Maid.new()
	m:GiveTask(function() flag = true end)
	m:Cleanup()
	assert(flag == true)
end)

runTest("Debounce", function()
	local seen
	local f = Modules.Debounce.debounce(function(v) seen = v end, 0.01)
	f(7)
	task.wait(0.05)
	assert(seen == 7)
end)

runTest("Timer", function()
	local seen
	Modules.Timer.setTimeout(function() seen = true end, 0.01)
	task.wait(0.05)
	assert(seen == true)
end)

runTest("TweenUtil (number)", function()
	Modules.TweenUtil.tween(0, 1, TweenInfo.new(0), function(_) end)
end)

runTest("InstanceUtil", function()
	local f = Modules.InstanceUtil.create("Folder", { Name = "_SrvTestFolder", Parent = workspace })
	assert(f and f.Name == "_SrvTestFolder")
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
	Modules.CollectionUtil.addTag(p, "_SrvTmpTag")
	Modules.CollectionUtil.removeTag(p, "_SrvTmpTag")
end)

runTest("TimeUtil", function()
	local s = Modules.TimeUtil.formatDuration(61)
	assert(type(s) == "string")
end)

runTest("PromiseUtil", function()
	local ok = false
	Modules.PromiseUtil.resolve(5):andThen(function(v) ok = (v == 5) end)
	task.wait()
	assert(ok)
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

runTest("RaycastUtil (params only)", function()
	local params = Modules.RaycastUtil.params({}, "Exclude")
	assert(typeof(params) == "RaycastParams")
end)

runTest("PatternUtil (presence)", function()
	assert(type(Modules.PatternUtil) == "table")
end)

runTest("PlayerUtil (presence)", function()
	assert(type(Modules.PlayerUtil) == "table")
end)

runTest("SoundUtil (presence)", function()
	assert(type(Modules.SoundUtil) == "table")
end)

-- Server-only surface checks (don't hit network/teleport/datastore in tests)
runTest("TeleportUtil (server)", function()
	assert(type(Modules.TeleportUtil) == "table")
	assert(type(Modules.TeleportUtil.teleportToPlace) == "function")
	assert(type(Modules.TeleportUtil.teleportInServer) == "function")
end)

runTest("HttpUtil (server)", function()
	assert(type(Modules.HttpUtil) == "table")
	assert(type(Modules.HttpUtil.get) == "function")
end)

runTest("DataStoreUtil (server)", function()
	local store = Modules.DataStoreUtil.getStore("UF_Test")
	assert(store ~= nil)
end)

runTest("LeaderstatsUtil (server)", function()
	Modules.LeaderstatsUtil.bindAutoSetup(game:GetService("Players"))
end)

runTest("MatchmakingUtil (server)", function()
	local mm = Modules.MatchmakingUtil.new(0, 2, { retries = 0 })
	assert(mm ~= nil)
end)

print(string.format("AllModules.server: %d passed, %d failed (total %d)", passed, failed, total))
if failed > 0 then
	warn("Some server tests failed.")
end
