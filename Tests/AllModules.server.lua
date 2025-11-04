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

-- New shared modules
runTest("VectorUtil", function()
	local a = Vector3.new(1, 0, 0)
	local b = Vector3.new(0, 0, 1)
	local ang = Modules.VectorUtil.angleBetween(a, b)
	assert(math.abs(ang - math.pi/2) < 1e-4)
	local clamped = Modules.VectorUtil.clampMagnitude(Vector3.new(10,0,0), 2)
	assert(math.abs(clamped.Magnitude - 2) < 1e-4)
end)

runTest("FormatUtil", function()
	assert(Modules.FormatUtil.withCommas(1234567) == "1,234,567")
	local abbr = Modules.FormatUtil.abbreviate(15300, 1)
	assert(abbr:find("k"))
	assert(Modules.FormatUtil.percent(0.125, 1) == "12.5%")
	assert(Modules.FormatUtil.bytes(1536):find("KB"))
end)

runTest("UUIDUtil", function()
	local g = Modules.UUIDUtil.guid()
	assert(type(g) == "string" and #g > 10)
	local s = Modules.UUIDUtil.randomString(8)
	assert(#s == 8)
	local short = Modules.UUIDUtil.shortId(12)
	assert(#short == 12)
end)

runTest("CacheUtil", function()
	local cache = Modules.CacheUtil.new(60, 10)
	local n = 0
	local v1 = cache:getOrCompute("a", function() n += 1 return 5 end)
	local v2 = cache:getOrCompute("a", function() n += 1 return 6 end)
	assert(v1 == 5 and v2 == 5 and n == 1)
end)

runTest("Observable", function()
	local o = Modules.Observable.new(1)
	local seen
	local conn = o.Changed:Connect(function(v) seen = v end)
	o:set(2)
	task.wait()
	assert(seen == 2 and o:get() == 2)
	conn:Disconnect()
	o:Destroy()
end)

-- Batch 2 shared modules
runTest("GeometryUtil", function()
	local minV, maxV = Modules.GeometryUtil.aabbFromPoints({ Vector3.new(0,0,0), Vector3.new(2,3,4) })
	assert(minV and maxV and maxV.X == 2 and maxV.Y == 3 and maxV.Z == 4)
	local cf, size = Modules.GeometryUtil.aabbToCFrameSize(minV, maxV)
	assert(typeof(cf) == "CFrame" and typeof(size) == "Vector3")
	local hit = Modules.GeometryUtil.rayPlaneIntersection(Vector3.new(0,0,0), Vector3.new(0,1,0), Vector3.new(0,5,0), Vector3.new(0,1,0))
	assert(hit and math.abs(hit.Y - 5) < 1e-4)
	local cp = Modules.GeometryUtil.closestPointOnSegment(Vector3.new(0,0,0), Vector3.new(10,0,0), Vector3.new(5,5,0))
	assert(typeof(cp) == "Vector3")
end)

runTest("EasingUtil", function()
	local v1 = Modules.EasingUtil.quadIn(0.5)
	local v2 = Modules.EasingUtil.quadOut(0.5)
	local v3 = Modules.EasingUtil.sineInOut(0.5)
	assert(v1 < 0.5 and v2 > 0.5 and math.abs(v3 - 0.5) < 1e-6)
end)

runTest("DeepTableUtil", function()
	local a = { x = { y = 1 }, z = 2 }
	local b = { x = { y = 3, k = 4 } }
	local m = Modules.DeepTableUtil.deepMerge(Modules.DeepTableUtil.deepClone(a), b)
	assert(m.x.y == 3 and m.x.k == 4 and m.z == 2)
	local v = Modules.DeepTableUtil.getIn(m, {"x", "k"})
	assert(v == 4)
	local m2 = Modules.DeepTableUtil.setIn(m, {"x","y"}, 10)
	assert(m2.x.y == 10 and m.x.y == 3)
	assert(Modules.DeepTableUtil.equalsDeep(m2, m2))
end)

runTest("StatUtil", function()
	local v = Modules.StatUtil.ema(nil, 10, 0.5)
	v = Modules.StatUtil.ema(v, 0, 0.5)
	assert(v and v > 0 and v < 10)
	local r = Modules.StatUtil.Running(); r:push(1); r:push(3)
	assert(r:mean() == 2 and r.min == 1 and r.max == 3)
end)

runTest("HashUtil", function()
	local h1 = Modules.HashUtil.stringHash("abc")
	local h2 = Modules.HashUtil.stableHash({ a = 1, b = 2 })
	assert(type(h1) == "number" and type(h2) == "number")
end)

-- Data helpers
runTest("LRUCache", function()
	local LRU = Modules.LRUCache
	local c = LRU.new(2)
	c:set("a", 1)
	c:set("b", 2)
	assert(c:get("a") == 1)
	c:set("c", 3) -- evict b
	assert(c:get("b") == nil and c:get("c") == 3)
end)

runTest("Memoize", function()
	local calls = 0
	local f = function(x, y) calls += 1; return x + y end
	local mf = select(1, Modules.Memoize.wrap(f, { capacity = 8 }))
	assert(mf(1,2) == 3 and mf(1,2) == 3 and calls == 1)
end)

runTest("EventBus", function()
	local bus = Modules.EventBus.new()
	local seen
	local conn = bus:subscribe("tick", function(v) seen = v end)
	bus:publish("tick", 42)
	task.wait()
	assert(seen == 42)
	conn:Disconnect(); bus:Destroy()
end)

runTest("Deque", function()
	local dq = Modules.Deque.new()
	dq:pushLeft(1); dq:pushRight(2)
	assert(dq:popLeft() == 1 and dq:popRight() == 2)
end)

runTest("PriorityQueue", function()
	local pq = Modules.PriorityQueue.new()
	pq:push(5); pq:push(1); pq:push(3)
	assert(pq:pop() == 1 and pq:pop() == 3 and pq:pop() == 5)
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

runTest("MessagingServiceUtil (server)", function()
	assert(type(Modules.MessagingServiceUtil) == "table")
	assert(type(Modules.MessagingServiceUtil.publish) == "function")
	assert(type(Modules.MessagingServiceUtil.subscribe) == "function")
end)

runTest("MemoryStoreUtil (server)", function()
	assert(type(Modules.MemoryStoreUtil) == "table")
	local q = Modules.MemoryStoreUtil.queue("UF_TestQueue")
	assert(type(q.enqueue) == "function")
	local m = Modules.MemoryStoreUtil.map("UF_TestMap")
	assert(type(m.increment) == "function")
end)

runTest("BadgeUtil (server)", function()
	assert(type(Modules.BadgeUtil) == "table")
	assert(type(Modules.BadgeUtil.hasBadge) == "function")
end)

runTest("GroupUtil (server)", function()
	assert(type(Modules.GroupUtil) == "table")
	assert(type(Modules.GroupUtil.getRankInGroup) == "function")
end)

runTest("MarketplaceUtil (server)", function()
	assert(type(Modules.MarketplaceUtil) == "table")
	assert(type(Modules.MarketplaceUtil.ownsGamePass) == "function")
end)

runTest("PolicyUtil (server)", function()
	assert(type(Modules.PolicyUtil) == "table")
	assert(type(Modules.PolicyUtil.getPolicy) == "function")
end)

runTest("BanUtil (server)", function()
	assert(type(Modules.BanUtil) == "table")
	assert(type(Modules.BanUtil.ban) == "function")
end)

runTest("WebhookUtil (server)", function()
	assert(type(Modules.WebhookUtil) == "table")
	assert(type(Modules.WebhookUtil.postJson) == "function")
end)

runTest("ChatFilterUtil (server)", function()
	assert(type(Modules.ChatFilterUtil) == "table")
	assert(type(Modules.ChatFilterUtil.filterForBroadcast) == "function")
end)

runTest("AccessControlUtil (server)", function()
	assert(type(Modules.AccessControlUtil) == "table")
	local ok = Modules.AccessControlUtil.canUseFeature
	assert(type(ok) == "function")
end)

runTest("JobScheduler (server)", function()
	assert(type(Modules.JobScheduler) == "table")
	local s = Modules.JobScheduler.new("UF_TestJobs", { poll = 0.01 })
	assert(s and s.enqueue and s.startWorker and s.stopWorker)
	s:stopWorker()
end)

runTest("AuditLogUtil (server)", function()
	assert(type(Modules.AuditLogUtil) == "table")
	local logger = Modules.AuditLogUtil.new(nil)
	logger:log("test", { a = 1 })
	logger:start(); logger:stop()
end)

runTest("CharacterScaleUtil (server)", function()
	assert(type(Modules.CharacterScaleUtil) == "table")
	-- Create a dummy R15-like Humanoid; scaling values will be NumberValues on Humanoid
	local model = Instance.new("Model")
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model
	local ok, err = Modules.CharacterScaleUtil.setUniformScale(humanoid, 1.1)
	assert(ok, err)
	local scales = Modules.CharacterScaleUtil.getScales(humanoid)
	assert(scales and math.abs(scales.height - 1.1) < 1e-6)
	Modules.CharacterScaleUtil.reset(humanoid)
	scales = Modules.CharacterScaleUtil.getScales(humanoid)
	assert(math.abs(scales.height - 1) < 1e-6)
	model:Destroy()
end)

runTest("CharacterMovementUtil (server)", function()
	assert(type(Modules.CharacterMovementUtil) == "table")
	local model = Instance.new("Model")
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model
	local ok = Modules.CharacterMovementUtil.setWalkSpeed(humanoid, 24)
	assert(ok and math.abs(humanoid.WalkSpeed - 24) < 1e-6)
	Modules.CharacterMovementUtil.setJumpPower(humanoid, 60)
	assert(humanoid.UseJumpPower and humanoid.JumpPower == 60)
	local ok2, restore = Modules.CharacterMovementUtil.tempWalkSpeed(humanoid, 12, { mode = "add" })
	assert(ok2 and type(restore) == "function")
	restore()
	model:Destroy()
end)

runTest("CharacterHealthUtil (server)", function()
	assert(type(Modules.CharacterHealthUtil) == "table")
	local model = Instance.new("Model")
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model
	Modules.CharacterHealthUtil.setMaxHealth(humanoid, 200)
	assert(humanoid.MaxHealth == 200)
	Modules.CharacterHealthUtil.damage(humanoid, 50)
	assert(humanoid.Health == 150)
	local ok, disable = Modules.CharacterHealthUtil.setInvulnerable(humanoid, true)
	assert(ok and type(disable) == "function")
	Modules.CharacterHealthUtil.damage(humanoid, 50)
	-- damage should be negated
	assert(humanoid.Health == 150)
	disable()
	model:Destroy()
end)

runTest("CharacterVisibilityUtil (server)", function()
	assert(type(Modules.CharacterVisibilityUtil) == "table")
	local model = Instance.new("Model")
	local humanoid = Instance.new("Humanoid")
	local part = Instance.new("Part")
	part.Parent = model
	humanoid.Parent = model
	local ok = Modules.CharacterVisibilityUtil.setInvisible(model, true)
	assert(ok and part.Transparency == 1)
	Modules.CharacterVisibilityUtil.setInvisible(model, false)
	assert(part.Transparency == 0)
	model:Destroy()
end)

runTest("CharacterAppearanceUtil (server)", function()
	assert(type(Modules.CharacterAppearanceUtil) == "table")
	local model = Instance.new("Model")
	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model
	local bc = Modules.CharacterAppearanceUtil.setBodyColors(model, { Head = BrickColor.new("Bright yellow") })
	assert(bc and bc:IsA("BodyColors"))
	model:Destroy()
end)

print(string.format("AllModules.server: %d passed, %d failed (total %d)", passed, failed, total))
if failed > 0 then
	warn("Some server tests failed.")
end
