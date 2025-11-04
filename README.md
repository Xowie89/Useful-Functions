# Useful Functions (Roblox Luau)

A collection of lightweight, reusable Roblox utility modules. Drop the `Modules` folder into ServerScriptService or ReplicatedStorage and require from `Modules/init.lua`.

## Quick start

```lua
-- Recommended: top-level ModuleScript next to the Modules folder
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage:WaitForChild("UsefulFunctions"))

local Signal = Modules.Signal
local Maid = Modules.Maid
local Debounce = Modules.Debounce
local Timer = Modules.Timer
local TweenUtil = Modules.TweenUtil
local InstanceUtil = Modules.InstanceUtil
local TableUtil = Modules.TableUtil
local StringUtil = Modules.StringUtil
local MathUtil = Modules.MathUtil
```

Alternative (no top-level ModuleScript):

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- IMPORTANT: You can't require a Folder. Require the `init` ModuleScript inside it.
local Modules = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("init"))
```

Bundles at a glance:

- Shared (client + server): `require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Contents overview:

- Core shared: Signal, Maid, Debounce, Timer, TweenUtil, InstanceUtil, TableUtil, StringUtil, TimeUtil
- Math/geometry: MathUtil, VectorUtil, CFrameUtil, GeometryUtil, EasingUtil, RandomUtil, RaycastUtil, ColorUtil
- Data helpers: CacheUtil, LRUCache, Memoize, EventBus, Deque, PriorityQueue, HashUtil, UUIDUtil, Observable, PatternUtil, StateMachine, RateLimiter, CooldownUtil, PromiseUtil, CollectionUtil, PlayerUtil, SoundUtil
- Client UI/input: CameraUtil, NotificationUtil/Queue, ModalUtil, ProgressBar, Input/Device/ScreenResize/Cursor/CursorRay, ScreenFade, GuiDrag, Viewport, ButtonFX, Layout, KeybindHint, ScreenShake, Highlight, Tooltip, TouchGesture, OffscreenIndicator, Scroll, Slider, Haptic
- Server services: TeleportUtil, MatchmakingUtil, HttpUtil, DataStoreUtil, LeaderstatsUtil, MessagingServiceUtil, MemoryStoreUtil, BadgeUtil, GroupUtil, MarketplaceUtil, PolicyUtil, BanUtil, WebhookUtil, ChatFilterUtil, AccessControlUtil, JobScheduler, AuditLogUtil

## Using with Rojo (recommended for GitHub repos)

This repo includes a `default.project.json` that maps shared/client modules to ReplicatedStorage and server-only modules to ServerScriptService:

```json
{
	"name": "UsefulFunctions",
	"tree": {
		"$className": "DataModel",
		"ReplicatedStorage": {
			"UsefulFunctions": { "$path": "UsefulFunctions.lua" },
			"UsefulFunctionsClient": { "$path": "UsefulFunctionsClient.lua" },
			"Modules": {
				"$className": "Folder",
				"init": { "$path": "Modules/init.lua" },
				"Shared": { "$className": "Folder", "init": { "$path": "Modules/Shared/init.lua" }},
				"Client": { "$className": "Folder", "init": { "$path": "Modules/Client/init.lua" }}
			}
		},
		"ServerScriptService": {
			"UsefulFunctions": {
				"$className": "Folder",
				"UsefulFunctionsServer": { "$path": "UsefulFunctionsServer.lua" },
				"Modules": { "$className": "Folder", "Server": { "$className": "Folder", "init": { "$path": "Modules/Server/init.lua" }}}
			}
		}
	}
}
```

Note on Studio Explorer mapping:

- For convenience, this project maps most Shared modules directly under `ReplicatedStorage` as ModuleScripts (e.g. `ReplicatedStorage.Signal`, `ReplicatedStorage.Maid`, …) in addition to the `ReplicatedStorage/Modules/Shared` folder and the bundle entries. You can either require via the bundles (recommended for most cases) or directly require individual modules you see in Explorer.

With that mapping, in Studio you can require:

```lua
-- Shared (client + shared)
local Modules = require(game.ReplicatedStorage.UsefulFunctions)
-- Client-only
local ClientModules = require(game.ReplicatedStorage.UsefulFunctionsClient)
-- Server-only
local ServerModules = require(game.ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
```

Alternatively, access server/client-only modules via their bundles:

```lua
-- Server-only example (TeleportUtil)
local ServerModules = require(game.ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
local TeleportUtil = ServerModules.TeleportUtil
```

## Subfolders: Shared / Client / Server

- Shared: ReplicatedStorage.Modules.Shared -> safe for both server and client. Also exposed by `require(ReplicatedStorage.UsefulFunctions)`.
- Client: ReplicatedStorage.Modules.Client -> UI and client helpers. Exposed by `require(ReplicatedStorage.UsefulFunctionsClient)`.
- Server: ServerScriptService.UsefulFunctions.Modules.Server -> server-only. Exposed by `require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`.

## Testing

This repo includes simple smoke tests for all modules.

- Client tests: `Tests/AllModules.client.lua` (runs as a LocalScript)
- Server tests: `Tests/AllModules.server.lua` (runs as a Script)

If you sync using the provided `default.project.json`, these are automatically mapped so they run when you press Play in Studio:

- Client test is placed under StarterPlayerScripts
- Server test is placed under ServerScriptService/Tests

Watch the Output window for [PASS]/[FAIL] lines and a summary for each side. Tests are conservative and avoid external calls (no real teleports/HTTP/DataStores).

## Modules

Below is a quick tour of the most used utilities. All names are accessed via the bundles:
- Shared: `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client: `local Modules = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server: `local Modules = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

### Signal
Lightweight event wrapper.

```lua
local signal = Modules.Signal.new()
local conn = signal:Connect(function(msg) print("got", msg) end)
signal:Fire("hello")
conn:Disconnect()
signal:Destroy()
```

### Maid
Cleanup manager for connections, instances, and functions.

```lua
local maid = Modules.Maid.new()
maid:GiveTask(workspace.ChildAdded:Connect(function() end))
maid:GiveTask(function() print("cleanup") end)
maid:Cleanup()
```

### Debounce
Debounce & throttle helpers.

```lua
local onResize = Modules.Debounce.debounce(function(w, h) print(w, h) end, 0.25)
onResize(800, 600)
```

### Timer
Simple `setTimeout` / `setInterval`.

```lua
Modules.Timer.setTimeout(function() print("once") end, 1)
local handle = Modules.Timer.setInterval(function() print("tick") end, 2)
-- handle.Stop()
```

### TweenUtil
Tween numbers or properties.

```lua
Modules.TweenUtil.tween(0, 1, TweenInfo.new(0.5), function(v)
    print(string.format("progress %.2f", v))
end)

local gui = Instance.new("Frame")
gui.Size = UDim2.fromScale(0, 0)
Modules.TweenUtil.tween(gui, { Size = UDim2.fromScale(1, 1) }, TweenInfo.new(0.25))
```

### TeleportUtil (server)
Cross-place and in-server teleports with retries/backoff.

```lua
local ServerModules = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
local TeleportUtil = ServerModules.TeleportUtil

TeleportUtil.teleportInServer(player, workspace.SpawnLocation, { keepOrientation = true, offset = Vector3.new(0,2,0) })
local ok, err = TeleportUtil.teleportToPlace(1234567890, player, { from = game.PlaceId })
```

### NotificationQueue (client)
Queued and stacked toasts.

```lua
local nq = Modules.NotificationQueue.new({ maxVisible = 3 })
nq:enqueue("You picked up a coin")
nq:setPosition(UDim2.new(0.5, 0, 0.12, 0), Vector2.new(0.5, 0))
```

### ModalUtil (client)
Promise-based confirms/prompts.

```lua
Modules.ModalUtil.confirm({ title = "Confirm", message = "Start?", buttons = {"Yes","No"} }):andThen(function(answer)
    print("answer", answer)
end)
```

### CooldownUtil
Per-key cooldown tracker (client or server).

```lua
local cd = Modules.CooldownUtil.new(2)
if not cd:use("dash") then
    print("dash ready in", string.format("%.2f", cd:timeRemaining("dash")), "s")
end
```

### ClientRateLimiter (client)
Advisory client-side limiter (always validate on server too).

```lua
local rl = Modules.ClientRateLimiter.new(5, 2)
local ok, remaining = rl:allow("fire")
```

### InstanceUtil
Build/fetch/wait/destroy helpers.

```lua
local folder = Modules.InstanceUtil.getOrCreate(workspace, "Folder", "Stuff")
local part = Modules.InstanceUtil.create("Part", { Name = "P", Parent = folder, Anchored = true })
```

### TableUtil

```lua
Modules.TableUtil.shallowEqual({a=1},{a=1}) -- true
for k,v in Modules.TableUtil.pairsByKeys({b=2, a=1}) do print(k,v) end
```

### StringUtil
Trim, split, join, slugify, etc.

```lua
Modules.StringUtil.trim("  hi  ") -- "hi"
Modules.StringUtil.slugify("Hello World!!") -- "hello-world"
```

### MathUtil

```lua
Modules.MathUtil.remap(5, 0, 10, 0, 1, true) -- 0.5
```

### VectorUtil

```lua
local a, b = Vector3.new(1,0,0), Vector3.new(0,0,1)
local ang = Modules.VectorUtil.angleBetween(a, b) -- ~math.pi/2
local flat = Modules.VectorUtil.horizontal(Vector3.new(1,5,2)) -- Vector3.new(1,0,2)
```

### RaycastUtil

```lua
local params = Modules.RaycastUtil.params({character}, "Exclude")
Modules.RaycastUtil.ignoreCharacter(params, player)
local hit = Modules.RaycastUtil.raycastFromTo(Vector3.new(0,10,0), Vector3.new(0,0,0), params)
```

### ColorUtil

```lua
local c = Modules.ColorUtil.fromHex("#FFAA00")
local lighter = Modules.ColorUtil.lighten(c, 0.2)
print(Modules.ColorUtil.toHex(lighter))
```

### HttpUtil (server)

```lua
local ok, res, err = Modules.HttpUtil.get("https://httpbin.org/get", nil, { retries = 2 })
```

### DataStoreUtil (server)

```lua
local store = Modules.DataStoreUtil.getStore("PlayerData")
local ok, data = Modules.DataStoreUtil.get(store, player.UserId)
```

### CollectionUtil

```lua
Modules.CollectionUtil.addTag(part, "Enemy")
local conn = Modules.CollectionUtil.onAdded("Enemy", function(inst) print("enemy tagged:", inst) end)
```

### TimeUtil

```lua
Modules.TimeUtil.formatDuration(3671) -- "01:01:11"
Modules.TimeUtil.iso8601() -- e.g. "2025-11-03T12:34:56Z"
```

### SoundUtil

```lua
local sound, handle = Modules.SoundUtil.play("rbxassetid://123456", { parent = workspace, volume = 0.7 })
-- handle.Stop(); handle.FadeOut(0.25)
```

### FormatUtil

```lua
Modules.FormatUtil.withCommas(1234567) -- "1,234,567"
Modules.FormatUtil.abbreviate(15300) -- "15.3k"
Modules.FormatUtil.percent(0.125, 1) -- "12.5%"
Modules.FormatUtil.bytes(1536) -- "1.5 KB"
```

### CameraUtil (client)

```lua
Modules.CameraUtil.setSubject(nil)
Modules.CameraUtil.tweenTo(CFrame.new(0,20,0), TweenInfo.new(1))
```

### InputUtil (client)

Keyboard/mouse/touch helpers and simple action binding.

```lua
local InputUtil = Modules.InputUtil

local unbind = InputUtil.bindAction("Jump", Enum.KeyCode.Space, function()
	print("Space pressed")
end)

print("isKeyDown:", InputUtil.isKeyDown(Enum.KeyCode.W))
print("textFocused:", InputUtil.isTextBoxFocused())
-- Later: unbind()
```

### DeviceUtil (client)

Classify device and get viewport/safe-area info.

```lua
local DeviceUtil = Modules.DeviceUtil
print("touch device:", DeviceUtil.isTouchDevice())
print("viewport:", DeviceUtil.getViewportSize())
print("safe area inset:", DeviceUtil.getSafeAreaInset())
```

### ScreenFadeUtil (client)

Lightweight screen fade overlay attached to PlayerGui.

```lua
local ScreenFadeUtil = Modules.ScreenFadeUtil
-- Fade to black over 0.5s and then back over 0.5s
ScreenFadeUtil.fadeIn(0.5, Color3.new(0,0,0), 1)
task.wait(0.6)
ScreenFadeUtil.fadeOut(0.5)
```

### GuiDragUtil (client)

Make Frames draggable with optional clamping to screen.

```lua
local GuiDragUtil = Modules.GuiDragUtil
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 100)
frame.Position = UDim2.fromOffset(100, 100)
frame.Active = true
frame.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local stopDrag = GuiDragUtil.makeDraggable(frame, { clampToScreen = true })
-- Later: stopDrag()
```

### ViewportUtil (client)

Create a ready-to-use ViewportFrame with camera and model.

```lua
local ViewportUtil = Modules.ViewportUtil
local model = Instance.new("Model")
local part = Instance.new("Part")
part.Size = Vector3.new(4,4,4)
part.Parent = model

local viewport = ViewportUtil.createViewport(model, UDim2.fromOffset(200,200))
viewport.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
```

### CursorUtil (client)

Show/hide the cursor, set icon, and lock to center.

```lua
Modules.CursorUtil.show()
Modules.CursorUtil.setIcon("") -- or rbxassetid://...
Modules.CursorUtil.lockCenter(true)
-- Later
Modules.CursorUtil.lockCenter(false)
Modules.CursorUtil.hide()
```

### ScreenShakeUtil (client)

Quick camera shake with amplitude/frequency and optional decay.

```lua
local stop = Modules.ScreenShakeUtil.start({ amplitude = 0.8, frequency = 8, duration = 0.4, decay = true })
-- If needed, stop early: stop()
```

### HighlightUtil (client)

Add a Highlight to a part or model for emphasis.

```lua
local part = Instance.new("Part")
part.Parent = workspace
local h, cleanup = Modules.HighlightUtil.show(part, { color = Color3.fromRGB(255,200,50), duration = 1 })
-- Later: cleanup()
```

### TooltipUtil (client)

Attach a tooltip to a GuiObject; appears on hover and follows the mouse.

```lua
local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(120, 36)
button.Text = "Hover me"
button.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local unbind = Modules.TooltipUtil.bind(button, { text = "Click to start" })
-- Later: unbind()
```

### HapticUtil (client)

Controller vibration (if supported on the platform/controller).

```lua
-- Light rumble for 100ms on all connected gamepads
Modules.HapticUtil.rumbleAll(0.2, 0.1)
```

### ScreenResizeUtil (client)

Listen for viewport size changes.

```lua
local conn = Modules.ScreenResizeUtil.onResize(function(size)
	print("viewport:", size)
end)
-- Later: conn:Disconnect()
```

### CursorRayUtil (client)

Convert screen or mouse positions to rays, world points, or raycasts.

```lua
local origin, dir = Modules.CursorRayUtil.mouseRay(10)
local hit = Modules.CursorRayUtil.raycastMouse()
```

### ButtonFXUtil (client)

Quick hover/press scale effect for buttons.

```lua
local unbind = Modules.ButtonFXUtil.bind(someButton, { hoverScale = 1.05, pressScale = 0.97 })
-- Later: unbind()
```

### LayoutUtil (client)

Create common UI layout instances with defaults.

```lua
local list = Modules.LayoutUtil.createList({ parent = someFrame, padding = UDim.new(0, 6) })
local pad = Modules.LayoutUtil.createPadding({ parent = someFrame, left = UDim.new(0,12) })
```

### KeybindHintUtil (client)

Display on-screen keybind hints.

```lua
local id = Modules.KeybindHintUtil.show({ key = "E", text = "Interact" })
-- Later
Modules.KeybindHintUtil.remove(id)
```

### TouchGestureUtil (client)

Recognize basic multi-touch gestures: pan, pinch (zoom), rotate.

```lua
local ctrl = Modules.TouchGestureUtil.bind()
ctrl.OnPan:Connect(function(delta) print("pan", delta) end)
ctrl.OnPinch:Connect(function(d) print("pinch", d) end)
ctrl.OnRotate:Connect(function(r) print("rotate rad", r) end)
-- Later: ctrl:Destroy()
```

### OffscreenIndicatorUtil (client)

Show a small arrow around the screen edge pointing to a world target.

```lua
local stop = Modules.OffscreenIndicatorUtil.attach(workspace.SomePart, { margin = 16 })
-- Later: stop()
```

### ScrollUtil (client)

Smoothly scroll ScrollingFrames.

```lua
Modules.ScrollUtil.smoothScrollTo(someScrollingFrame, Vector2.new(0, 200))
```

### SliderUtil (client)

Minimal horizontal slider with value in [0..1].

```lua
local slider = Modules.SliderUtil.create({ parent = someGui, width = 200, initial = 0.25 })
slider.OnChanged:Connect(function(v) print("value", v) end)
slider:SetValue(0.5)
```

### CFrameUtil

```lua
local cf = Modules.CFrameUtil.lookAt(Vector3.new(0,5,0), Vector3.new(0,0,0))
local clamped = Modules.CFrameUtil.clampYaw(cf, -math.rad(90), math.rad(90))
```

### RandomUtil

```lua
local RNG = Modules.RandomUtil.new(42)
local pick = RNG:weighted({ {item="A", weight=1}, {item="B", weight=3} })
```

### RateLimiter

```lua
local limiter = Modules.RateLimiter.new(5, 2)
local ok, remaining = limiter:allow("player:"..player.UserId)
```

### NotificationUtil (client)

```lua
Modules.NotificationUtil.show("Welcome!", { duration = 3, stroke = true })
```

### StateMachine

```lua
local fsm = Modules.StateMachine.new("Idle")
fsm:addState("Idle", {})
fsm:addState("Run", {})
fsm:transition("Run")
```

### ProgressBar (client)

```lua
local bar = Modules.ProgressBar.create()
bar:SetText("Loading...")
bar:SetProgress(0)
```

### PromiseUtil

```lua
local Promise = Modules.PromiseUtil
Promise.retry(function()
    if math.random() < 0.5 then error("flaky") end
    return "ok"
end, 3, 0.5):andThen(print):catch(warn)
```

### PlayerUtil
### UUIDUtil

```lua
local id = Modules.UUIDUtil.guid()
local short = Modules.UUIDUtil.shortId(12)
local token = Modules.UUIDUtil.randomString(16)
```

### CacheUtil

```lua
local cache = Modules.CacheUtil.new(60, 100)
local value = cache:getOrCompute("player:"..player.UserId, function()
	return expensiveCompute()
end)
```

### Observable

```lua
local count = Modules.Observable.new(0)
count.Changed:Connect(function(v) print("count:", v) end)
count:set(1)
```

### LRUCache

```lua
local cache = Modules.LRUCache.new(128)
cache:set("a", 1)
cache:set("b", 2)
cache:set("c", 3) -- evicts least-recently used when capacity exceeded
local v = cache:get("a")
```

### Memoize

```lua
local slow = function(x, y)
	task.wait(0.05)
	return x + y
end
local fast, cache = Modules.Memoize.wrap(slow, { capacity = 64, ttl = 10 })
print(fast(1,2)) -- computed
print(fast(1,2)) -- cached
```

### EventBus

```lua
local bus = Modules.EventBus.new()
local conn = bus:subscribe("score:update", function(userId, score)
	print(userId, score)
end)
bus:publish("score:update", 123, 50)
conn:Disconnect(); bus:Destroy()
```

### Deque

```lua
local dq = Modules.Deque.new()
dq:pushLeft("first")
dq:pushRight("last")
print(dq:popLeft(), dq:popRight())
```

### PriorityQueue

```lua
local pq = Modules.PriorityQueue.new() -- min-heap
pq:push(5); pq:push(1); pq:push(3)
print(pq:pop(), pq:pop(), pq:pop()) -- 1, 3, 5
```

### GeometryUtil

```lua
local minV, maxV = Modules.GeometryUtil.aabbFromPoints({ Vector3.new(0,0,0), Vector3.new(2,3,4) })
local cf, size = Modules.GeometryUtil.aabbToCFrameSize(minV, maxV)
local hit = Modules.GeometryUtil.rayPlaneIntersection(Vector3.new(0,0,0), Vector3.new(0,1,0), Vector3.new(0,5,0), Vector3.new(0,1,0))
```

### EasingUtil

```lua
local t = 0.5
local a = Modules.EasingUtil.quadIn(t)
local b = Modules.EasingUtil.quadOut(t)
local c = Modules.EasingUtil.sineInOut(t)
```

### DeepTableUtil

```lua
local a = { x = { y = 1 }, z = 2 }
local b = { x = { y = 3, k = 4 } }
local merged = Modules.DeepTableUtil.deepMerge(Modules.DeepTableUtil.deepClone(a), b)
local v = Modules.DeepTableUtil.getIn(merged, {"x","k"}, 0) -- 4
local updated = Modules.DeepTableUtil.setIn(merged, {"x","y"}, 10) -- immutable style
```

### StatUtil

```lua
local v = Modules.StatUtil.ema(nil, 10, 0.5)
v = Modules.StatUtil.ema(v, 0, 0.5)
local run = Modules.StatUtil.Running(); run:push(1); run:push(3); print(run:mean())
```

### HashUtil

```lua
local h1 = Modules.HashUtil.stringHash("hello")
local h2 = Modules.HashUtil.stableHash({ a = 1, b = 2 })
```


```lua
local char = Modules.PlayerUtil.waitForCharacter(player, 5)
```

### LeaderstatsUtil (server)

```lua
Modules.LeaderstatsUtil.bindAutoSetup(game:GetService("Players"))
```

### MatchmakingUtil (server)

```lua
local mm = Modules.MatchmakingUtil.new(1234567890, 5)
mm:onMatched(function(players) print("matched", #players) end)
```

### MarketplaceUtil (server)

```lua
local ok, owns = Modules.MarketplaceUtil.ownsGamePass(player, 123456)
if not ok then warn("check failed") end
Modules.MarketplaceUtil.promptGamePass(player, 123456)

-- Dev product receipts
local router = Modules.MarketplaceUtil.createReceiptRouter({
	[1111] = function(player, receipt)
		-- grant product
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end,
})
Modules.MarketplaceUtil.bindProcessReceipt(router)
```

### PolicyUtil (server)

```lua
local policy = Modules.PolicyUtil.getPolicy(player)
local restricted = Modules.PolicyUtil.arePaidRandomItemsRestricted(player)
```

### MessagingServiceUtil (server)

```lua
local ok, err = Modules.MessagingServiceUtil.publish("uf:news", { text = "Hello" })
local sub = Modules.MessagingServiceUtil.subscribe("uf:news", function(data)
	print("got message:", data and data.text)
end)
-- Later: sub:Disconnect()
```

### MemoryStoreUtil (server)

```lua
local q = Modules.MemoryStoreUtil.queue("uf:jobs")
q.enqueue({ job = "cache-warm" }, 60)
-- local ok, entries = q.tryDequeue(1, 0)

local map = Modules.MemoryStoreUtil.map("uf:counters")
map.increment("visits", 1, 60)
```

### BadgeUtil (server)

```lua
local ok, owned = Modules.BadgeUtil.hasBadge(player, 123456)
Modules.BadgeUtil.awardIfNotOwned(player, 123456)
```

### GroupUtil (server)
Utilities for group checks and ranks.

```lua
local rank = Modules.GroupUtil.getRankInGroup(player, 987654)
local isAdmin = Modules.GroupUtil.isInGroup(player, 987654, 200)
```
### BanUtil (server)

```lua
Modules.BanUtil.ban(player, "Exploiting", 24*3600)
local shouldKick, message = Modules.BanUtil.shouldKick(player)
```

### WebhookUtil (server)
Simple JSON webhook posting.

```lua
local ok, res = Modules.WebhookUtil.postJson("https://example.com/webhook", { content = "Hello" })
```
### ChatFilterUtil (server)

```lua
local ok, filtered = Modules.ChatFilterUtil.filterForBroadcast("hello", player.UserId)
```

### AccessControlUtil (server)

```lua
local can, reason = Modules.AccessControlUtil.canUseFeature(player, {
	group = { id = 987654, minRank = 100 },
	gamePassId = 123456,
	requireVoice = true,
})
if not can then warn("blocked:", reason) end
```

### JobScheduler (server)

```lua
local scheduler = Modules.JobScheduler.new("uf:jobs", { poll = 0.5 })
scheduler:startWorker(function(payload)
	print("processing", payload.kind)
end)
scheduler:enqueue({ kind = "warm-cache" }, 60)
-- Later: scheduler:stopWorker()
```

### AuditLogUtil (server)

```lua
local logger = Modules.AuditLogUtil.new("https://example.com/webhook", { batchSize = 10, flushInterval = 5 })
logger:start()
logger:log("player_join", { userId = player.UserId })
-- Later: logger:stop()
```

### CharacterScaleUtil (server)

Resize player characters (R15) by setting/tweening humanoid scale values.

```lua
local ServerModules = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
local CS = ServerModules.CharacterScaleUtil

-- Uniform scale
CS.setUniformScale(player, 1.1) -- or pass humanoid

-- Individual scales
CS.setScale(player, { height = 1.05, width = 0.95, depth = 1.0, head = 1.1 })

-- Tween to scale over time
CS.tweenUniformScale(player, 1.2, TweenInfo.new(0.5))

-- Read/reset
local s = CS.getScales(player)
CS.reset(player)
```

## Folder placement
- ServerScriptService: best for server-only utilities (TeleportUtil usage).
- ReplicatedStorage: for shared modules (most utilities).

## Notes
- Written in Luau and safe for vanilla Roblox Studio.
- Minimal dependencies; each file is standalone.
