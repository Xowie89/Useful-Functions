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
	c:set("c", 3) -- evicts least recently used (b)
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

runTest("InputUtil (client)", function()
	local unbind = Modules.InputUtil.bindAction("_test_action", Enum.KeyCode.F, function() end)
	assert(type(unbind) == "function")
	unbind()
	-- should not throw
	Modules.InputUtil.isTextBoxFocused()
end)

runTest("DeviceUtil (client)", function()
	local isTouch = Modules.DeviceUtil.isTouchDevice()
	assert(type(isTouch) == "boolean")
	local vp = Modules.DeviceUtil.getViewportSize()
	assert(typeof(vp) == "Vector2")
end)

runTest("ScreenFadeUtil (client)", function()
	-- zero-duration to keep it instant
	Modules.ScreenFadeUtil.fadeIn(0, Color3.new(0,0,0), 0)
	Modules.ScreenFadeUtil.fadeOut(0)
end)

runTest("GuiDragUtil (client)", function()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(100, 50)
	frame.Active = true
	frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	local stop = Modules.GuiDragUtil.makeDraggable(frame, { clampToScreen = true })
	assert(type(stop) == "function")
	stop()
end)

runTest("ViewportUtil (client)", function()
	local model = Instance.new("Model")
	local p = Instance.new("Part")
	p.Parent = model
	local viewport = Modules.ViewportUtil.createViewport(model, UDim2.fromOffset(64,64))
	assert(viewport.ClassName == "ViewportFrame")
end)

runTest("CursorUtil (client)", function()
	Modules.CursorUtil.show()
	Modules.CursorUtil.hide()
	Modules.CursorUtil.setIcon("")
	Modules.CursorUtil.lockCenter(false)
	Modules.CursorUtil.lockCenter(true)
	assert(Modules.CursorUtil.isLocked() == true)
	Modules.CursorUtil.lockCenter(false)
end)

runTest("ScreenShakeUtil (client)", function()
	local stop = Modules.ScreenShakeUtil.start({ amplitude = 0, frequency = 0, duration = 0.01 })
	assert(type(stop) == "function")
	stop()
end)

runTest("HighlightUtil (client)", function()
	local p = Instance.new("Part")
	p.Parent = workspace
	local h, cleanup = Modules.HighlightUtil.show(p, { duration = 0.01 })
	assert(h and h:IsA("Highlight"))
	if cleanup then cleanup() end
	p:Destroy()
end)

runTest("TooltipUtil (client)", function()
	local player = game:GetService("Players").LocalPlayer
	local pg = player:FindFirstChildOfClass("PlayerGui") or Instance.new("PlayerGui", player)
	local screen = Instance.new("ScreenGui")
	screen.Parent = pg
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(100, 40)
	button.Position = UDim2.fromOffset(10, 10)
	button.Text = "Hover"
	button.Parent = screen
	local unbind = Modules.TooltipUtil.bind(button, { text = "Hello" })
	assert(type(unbind) == "function")
	unbind()
	screen:Destroy()
end)

runTest("HapticUtil (client)", function()
	-- Should not error even if no controller is connected
	local ok = Modules.HapticUtil.rumbleAll(0.1, 0.01)
	assert(type(ok) == "boolean")
end)

runTest("ScreenResizeUtil (client)", function()
	local got
	local conn = Modules.ScreenResizeUtil.onResize(function(size)
		got = size
	end)
	-- We cannot easily force a resize here, but API should connect and provide current size helper
	local vp = Modules.ScreenResizeUtil.getViewportSize()
	assert(typeof(vp) == "Vector2")
	conn:Disconnect()
end)

runTest("CursorRayUtil (client)", function()
	local origin, dir = Modules.CursorRayUtil.mouseRay(10)
	assert(origin and dir)
	local wp = Modules.CursorRayUtil.worldPointFromMouse(5)
	assert(typeof(wp) == "Vector3")
end)

runTest("ButtonFXUtil (client)", function()
	local player = game:GetService("Players").LocalPlayer
	local pg = player:FindFirstChildOfClass("PlayerGui") or Instance.new("PlayerGui", player)
	local screen = Instance.new("ScreenGui")
	screen.Parent = pg
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(80, 30)
	btn.Text = "Btn"
	btn.Parent = screen
	local unbind = Modules.ButtonFXUtil.bind(btn)
	assert(type(unbind) == "function")
	unbind()
	screen:Destroy()
end)

runTest("LayoutUtil (client)", function()
	local frame = Instance.new("Frame")
	local list = Modules.LayoutUtil.createList({ parent = frame })
	assert(list and list:IsA("UIListLayout"))
	local pad = Modules.LayoutUtil.createPadding({ parent = frame })
	assert(pad and pad:IsA("UIPadding"))
end)

runTest("KeybindHintUtil (client)", function()
	local id = Modules.KeybindHintUtil.show({ key = "E", text = "Interact" })
	assert(type(id) == "number")
	Modules.KeybindHintUtil.remove(id)
end)

runTest("TouchGestureUtil (client)", function()
	local ctrl = Modules.TouchGestureUtil.bind()
	assert(ctrl and ctrl.OnPan and ctrl.OnPinch and ctrl.OnRotate)
	if ctrl.Destroy then ctrl:Destroy() end
end)

runTest("OffscreenIndicatorUtil (client)", function()
	local p = Instance.new("Part")
	p.Position = Vector3.new(1e6, 1e6, 1e6) -- very far to ensure off-screen
	p.Parent = workspace
	local stop = Modules.OffscreenIndicatorUtil.attach(p, { margin = 16 })
	assert(type(stop) == "function")
	task.defer(function()
		stop()
		p:Destroy()
	end)
end)

runTest("ScrollUtil (client)", function()
	local player = game:GetService("Players").LocalPlayer
	local pg = player:FindFirstChildOfClass("PlayerGui") or Instance.new("PlayerGui", player)
	local screen = Instance.new("ScreenGui")
	screen.Parent = pg
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromOffset(200, 100)
	scroll.CanvasSize = UDim2.fromOffset(500, 500)
	scroll.Parent = screen
	local tween = Modules.ScrollUtil.smoothScrollTo(scroll, Vector2.new(50, 50), TweenInfo.new(0))
	assert(tween)
	screen:Destroy()
end)

runTest("SliderUtil (client)", function()
	local player = game:GetService("Players").LocalPlayer
	local pg = player:FindFirstChildOfClass("PlayerGui") or Instance.new("PlayerGui", player)
	local screen = Instance.new("ScreenGui")
	screen.Parent = pg
	local slider = Modules.SliderUtil.create({ parent = screen, width = 100, initial = 0 })
	local seen
	slider.OnChanged:Connect(function(v) seen = v end)
	slider:SetValue(0.5)
	assert(slider:GetValue() >= 0.49 and slider:GetValue() <= 0.51)
	screen:Destroy()
end)

print(string.format("AllModules.client: %d passed, %d failed (total %d)", passed, failed, total))
if failed > 0 then
	warn("Some client tests failed.")
end
