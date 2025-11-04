# Useful Functions — API Reference

A compact, practical API index for all modules. Grouped by bundle:

- Shared (client + server): `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `local Client = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Tip: In Studio, individual modules are also mapped under ReplicatedStorage/ServerScriptService for convenience, but bundle requires are recommended.

## Table of contents

- [Examples](#examples)
  - [Shared examples](#shared-examples)
  - [Client examples](#client-examples)
  - [Server examples](#server-examples)
- [Shared per-module examples](#shared-per-module-examples)
- [Client per-module examples](#client-per-module-examples)
- [Server per-module examples](#server-per-module-examples)
- [Shared modules](#shared-modules)
	- [Signal](#signal--lightweight-events)
	- [Maid](#maid--cleanup-aggregator)
	- [Debounce](#debounce--debouncethrottle)
	- [Timer](#timer--tiny-scheduler)
	- [TweenUtil](#tweenutil--tween-numbersprops)
	- [InstanceUtil](#instanceutil--instance-helpers)
	- [TableUtil](#tableutil--table-helpers)
	- [StringUtil](#stringutil--string-helpers)
	- [FormatUtil](#formatutil--formatting-helpers)
	- [MathUtil](#mathutil--math-helpers)
	- [CFrameUtil](#cframeutil--cframe-helpers)
	- [VectorUtil](#vectorutil--vector3-helpers)
	- [RaycastUtil](#raycastutil--raycast-helpers)
	- [ColorUtil](#colorutil--color3-helpers)
	- [CollectionUtil](#collectionutil--collectionservice-tags)
	- [TimeUtil](#timeutil--time-formatting)
	- [PatternUtil](#patternutil--lua-pattern-utils)
	- [PromiseUtil](#promiseutil--promises)
	- [PlayerUtil](#playerutil--playercharacter)
	- [SoundUtil](#soundutil--sound-helpers)
	- [RandomUtil](#randomutil--rng-convenience)
	- [RateLimiter](#ratelimiter--token-bucket)
	- [StateMachine](#statemachine--finite-state-machine)
	- [CooldownUtil](#cooldownutil--per-key-cooldowns)
	- [CacheUtil](#cacheutil--ttl-cache)
	- [UUIDUtil](#uuidutil--idsstrings)
	- [Observable](#observable--reactive-value)
	- [GeometryUtil](#geometryutil--geometry-helpers)
	- [EasingUtil](#easingutil--easing-curves)
	- [DeepTableUtil](#deeptableutil--deep-ops)
	- [StatUtil](#statutil--stats-helpers)
	- [HashUtil](#hashutil--hashes)
	- [LRUCache](#lrucache--lru-map-with-ttl)
	- [Memoize](#memoize--memoize-wrapper)
	- [EventBus](#eventbus--pubsub)
	- [Deque](#deque--double-ended-queue)
	- [PriorityQueue](#priorityqueue--min-heap)
- [Client modules](#client-modules)
	- [CameraUtil](#camerautil--camera-helpers)
	- [NotificationUtil](#notificationutil--quick-toasts)
	- [NotificationQueue](#notificationqueue--queuedstacked-toasts)
	- [ModalUtil](#modalutil--confirm-dialogs)
	- [ClientRateLimiter](#clientratelimiter--client-side-limiter)
	- [ProgressBar](#progressbar--simple-progress-ui)
	- [InputUtil](#inpututil--input-helpers)
	- [DeviceUtil](#deviceutil--device-info)
	- [ScreenFadeUtil](#screenfadeutil--fade-overlay)
	- [GuiDragUtil](#guidragutil--draggable-frames)
	- [ViewportUtil](#viewportutil--viewportframe-helpers)
	- [CursorUtil](#cursorutil--mouse-cursor)
	- [ScreenShakeUtil](#screenshakeutil--camera-shake)
	- [HighlightUtil](#highlightutil--highlight-partsmodels)
	- [TooltipUtil](#tooltiputil--hover-tooltips)
	- [HapticUtil](#hapticutil--gamepad-rumble)
	- [ScreenResizeUtil](#screenresizeutil--viewport-size-changes)
	- [CursorRayUtil](#cursorrayutil--screen-to-worldraycast)
	- [ButtonFXUtil](#buttonfxutil--hoverpress-scale-fx)
	- [LayoutUtil](#layoututil--ui-layout-builders)
	- [KeybindHintUtil](#keybindhintutil--keybind-hints)
	- [TouchGestureUtil](#touchgestureutil--panpinchrotate)
	- [OffscreenIndicatorUtil](#offscreenindicatorutil--edge-arrows)
	- [ScrollUtil](#scrollutil--smooth-scroll)
	- [SliderUtil](#sliderutil--horizontal-slider)
- [Server modules](#server-modules)
	- [TeleportUtil](#teleportutil--teleports)
	- [MatchmakingUtil](#matchmakingutil--queueparty-matching)
	- [HttpUtil](#httputil--http-requests)
	- [DataStoreUtil](#datastoreutil--datastore-helpers)
	- [LeaderstatsUtil](#leaderstatsutil--leaderstats)
	- [MessagingServiceUtil](#messagingserviceutil--pubsub)
	- [MemoryStoreUtil](#memorystoreutil--queuesmaps)
	- [BadgeUtil](#badgeutil--badges)
	- [GroupUtil](#grouputil--group-info)
	- [MarketplaceUtil](#marketplaceutil--purchases)
	- [PolicyUtil](#policyutil--policy-checks)
	- [BanUtil](#banutil--bans)
	- [WebhookUtil](#webhookutil--json-webhooks)
	- [ChatFilterUtil](#chatfilterutil--text-filter)
	- [AccessControlUtil](#accesscontrolutil--feature-gates)
	- [JobScheduler](#jobscheduler--background-jobs)
	- [AuditLogUtil](#auditlogutil--batched-logging)
	- [CharacterScaleUtil](#characterscaleutil--r15-scaling)
	- [CharacterMovementUtil](#charactermovementutil--movement-properties)
	- [CharacterAppearanceUtil](#characterappearanceutil--outfitscolorsaccessories)
	- [CharacterVisibilityUtil](#charactervisibilityutil--transparencyghost)
	- [CharacterHealthUtil](#characterhealthutil--healthinvulnerability)
- [Usage notes](#usage-notes)

---

<a id="examples"></a>
## Examples

Quick, copy-pasteable snippets showing typical use. Adjust paths to your game structure if needed.

<a id="shared-examples"></a>
### Shared examples

```lua
-- Require Shared bundle once
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage.UsefulFunctions)

-- Signal
local sig = Modules.Signal.new()
local conn = sig:Connect(function(msg, n)
	print("got:", msg, n)
end)
sig:Fire("hello", 123)
conn:Disconnect()

-- RaycastUtil: ray down from a point, ignoring Terrain
local p = Vector3.new(0, 50, 0)
local params = Modules.RaycastUtil.params({ workspace.Terrain }, "Exclude")
local hit = Modules.RaycastUtil.raycastFromTo(p, p + Vector3.new(0, -200, 0), params)
if hit then print("hit at", hit.Position) end

-- CacheUtil: compute-once cache with TTL
local cache = Modules.CacheUtil.new(60, 500) -- default TTL 60s, maxSize 500
local result = cache:getOrCompute("expensive", function()
	return "computed-value"
end, 120) -- per-call TTL 120s
```

<a id="client-examples"></a>
### Client examples

```lua
-- Require Client bundle on the client
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = require(ReplicatedStorage.UsefulFunctionsClient)

-- Notifications
Client.NotificationUtil.show("Welcome!", { duration = 2 })

-- Input: bind once to Space
Client.InputUtil.bindOnce("JumpOnce", function()
	print("Space pressed once")
end, true, { Enum.KeyCode.Space })

-- Screen fade
Client.ScreenFadeUtil.fadeIn(0.35, Color3.new(0,0,0))
task.wait(0.4)
Client.ScreenFadeUtil.fadeOut(0.35)

-- Cursor raycast (mouse)
local res = Client.CursorRayUtil.raycastMouse()
if res then
	print("Hovered part:", res.Instance, res.Position)
end
```

<a id="server-examples"></a>
### Server examples

```lua
-- Require Server bundle on the server
local ServerScriptService = game:GetService("ServerScriptService")
local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)

-- Teleport within server to a part
game.Players.PlayerAdded:Connect(function(player)
	local destinationPart = workspace:WaitForChild("SpawnLocation")
	Server.TeleportUtil.teleportInServer(player, destinationPart, { unseat = true })
end)

-- DataStore get/set
local store = Server.DataStoreUtil.getStore("PlayerData")
local function key(p) return ("p:%d"):format(p.UserId) end
game.Players.PlayerAdded:Connect(function(p)
	local ok, data = Server.DataStoreUtil.get(store, key(p))
	if ok and type(data) == "table" then
		print("loaded", data)
	end
	Server.DataStoreUtil.set(store, key(p), { coins = 10 })
end)

-- Leaderstats quick setup
game.Players.PlayerAdded:Connect(function(p)
	Server.LeaderstatsUtil.addInt(p, "Coins", 0)
	Server.LeaderstatsUtil.increment(p, "Coins", 5)
end)

-- Character utils: temporary sprint and invisibility
game.Players.PlayerAdded:Connect(function(p)
	-- grant sprint for 5 seconds
	Server.CharacterMovementUtil.tempWalkSpeed(p, 28, { mode = "set", duration = 5 })
	-- toggle invis for 3 seconds (non-colliding)
	Server.CharacterVisibilityUtil.setInvisible(p, true, { nonCollide = true })
	task.delay(3, function()
		Server.CharacterVisibilityUtil.setInvisible(p, false)
	end)
end)

-- MessagingService pub/sub
local sub = Server.MessagingServiceUtil.subscribe("uf:ping", function(data)
	print("got", data)
end)
Server.MessagingServiceUtil.publish("uf:ping", { hello = true })
```

<a id="shared-per-module-examples"></a>
## Shared per-module examples

Below are minimal examples for each Shared module. Require once:

```lua
local Modules = require(game:GetService("ReplicatedStorage").UsefulFunctions)
```

### Signal

```lua
local Signal = Modules.Signal
local sig = Signal.new()
local conn = sig:Connect(function(msg, n)
	print("Signal got:", msg, n)
end)
sig:Fire("hello", 123)
conn:Disconnect()
sig:Destroy()
```

### Maid

```lua
local Maid = Modules.Maid
local maid = Maid.new()
local conn = workspace.DescendantAdded:Connect(function() end)
maid:GiveTask(conn)
maid:GiveTask(function() print("cleanup callback") end)
maid:Cleanup()
```

### Debounce

```lua
local Debounce = Modules.Debounce
local run = Debounce.debounce(function()
	print("debounced call")
end, 0.3)
run(); run(); task.wait(0.4); run()

local throttle = Debounce.throttle(function()
	print("throttled")
end, 0.5)
for i=1,5 do throttle() end
```

### Timer

```lua
local Timer = Modules.Timer
Timer.setTimeout(function() print("later") end, 1)
local t = Timer.setInterval(function() print("tick") end, 0.5)
task.delay(2, t.Stop)
```

### TweenUtil

```lua
local TweenUtil = Modules.TweenUtil
local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenUtil.tweenAsync(someGui, info, { BackgroundTransparency = 0.2 })

-- Numeric tween with onStep
TweenUtil.tween(0, TweenInfo.new(0.5), function(alpha)
	someGui.ImageTransparency = 1 - alpha
end)
```

### InstanceUtil

```lua
local InstanceUtil = Modules.InstanceUtil
local frame = InstanceUtil.create("Frame", {
	Name = "MyFrame",
	Size = UDim2.fromScale(1, 0),
	BackgroundColor3 = Color3.fromRGB(30, 30, 30),
}, {
	InstanceUtil.create("UICorner", { CornerRadius = UDim.new(0, 8) }),
})
frame.Parent = script.Parent
```

### TableUtil

```lua
local T = Modules.TableUtil
local a = { x = 1, nested = { y = 2 } }
local b = T.copy(a, true)
local c = T.mergeDeep({ a = { b = 1 } }, { a = { c = 2 } })
print(T.equals({1,2},{1,2}))
```

### StringUtil

```lua
local S = Modules.StringUtil
print(S.trim("  hi  "))
print(S.startsWith("foobar","foo"))
print(S.slugify("Hello World!")) -- "hello-world"
```

### FormatUtil

```lua
local F = Modules.FormatUtil
print(F.withCommas(1234567))       -- 1,234,567
print(F.abbreviate(1250000, 1))    -- 1.3M
print(F.percent(0.256, 1))         -- 25.6%
print(F.bytes(1536000, 1))         -- 1.5 MB
print(F.timeAgo(3672))             -- 1h ago (or similar)
```

### MathUtil

```lua
local M = Modules.MathUtil
print(M.remap(5, 0, 10, 0, 1, true)) -- 0.5
print(M.roundTo(3.1415, 0.05))
print(M.chooseWeighted({ {item="A", weight=1}, {item="B", weight=3} }))
```

### CFrameUtil

```lua
local CFU = Modules.CFrameUtil
local cf = CFU.lookAt(Vector3.new(0,5,0), Vector3.new(10,5,0))
local yaw, pitch, roll = CFU.toYawPitchRoll(cf)
```

### VectorUtil

```lua
local VU = Modules.VectorUtil
local v = VU.clampMagnitude(Vector3.new(10, 0, 0), 5)
local angle = VU.angleBetween(Vector3.new(1,0,0), Vector3.new(0,0,1))
```

### RaycastUtil

```lua
local RU = Modules.RaycastUtil
local params = RU.params({ workspace.Terrain }, "Exclude")
local res = RU.raycast(Vector3.new(0,10,0), Vector3.new(0,-100,0), params)
if res then print("hit:", res.Instance, res.Position) end
```

### ColorUtil

```lua
local CU = Modules.ColorUtil
local gold = CU.fromHex("#ffcc00")
local darker = CU.darken(gold, 0.2)
```

### CollectionUtil

```lua
local Col = Modules.CollectionUtil
Col.addTag(workspace.Part, "Interactable")
print(Col.hasTag(workspace.Part, "Interactable"))
for _, inst in ipairs(Col.getTagged("Interactable")) do
	print("tagged:", inst:GetFullName())
end
```

### TimeUtil

```lua
local TU = Modules.TimeUtil
print(TU.formatDuration(3672)) -- e.g. "1h 1m 12s"
print(TU.iso8601())
```

### PatternUtil

```lua
local PU = Modules.PatternUtil
local escaped = PU.escapePattern("[a-z]+(test)")
local out, n = PU.replace("hello 123", "%d+", "#")
```

### PromiseUtil

```lua
local P = Modules.PromiseUtil
P.delay(0.2):andThen(function() print("done") end)
```

### PlayerUtil

```lua
local Pl = Modules.PlayerUtil
game.Players.PlayerAdded:Connect(function(p)
	local char = Pl.waitForCharacter(p, 10)
	if char then print("spawned:", char) end
end)
```

### SoundUtil

```lua
local SU = Modules.SoundUtil
local s, ctl = SU.play(1843512685, { parent = workspace, volume = 0.6 })
task.delay(1, function() ctl.FadeOut(0.5) end)
```

### RandomUtil

```lua
local R = Modules.RandomUtil
local rng = R.new(123)
print(rng:integer(1, 10))
print(rng:choice({"a","b","c"}))
```

### RateLimiter

```lua
local RL = Modules.RateLimiter
local limiter = RL.new(5, 2) -- capacity 5, refill 2 tokens/s
local ok, remaining = limiter:allow("shoot")
```

### StateMachine

```lua
local FSM = Modules.StateMachine
local fsm = FSM.new("Idle")
fsm:addState("Run", { onEnter = function() print("-> Run") end })
fsm:transition("Run")
```

### CooldownUtil

```lua
local CD = Modules.CooldownUtil
local cd = CD.new(2)
if cd:use("dash") then
	print("dash!")
end
```

### CacheUtil

```lua
local CacheUtil = Modules.CacheUtil
local cache = CacheUtil.new(60, 1000)
local v = cache:getOrCompute("key", function() return math.random() end, 30)
```

### UUIDUtil

```lua
local UUID = Modules.UUIDUtil
print(UUID.guid())
print(UUID.shortId(6))
```

### Observable

```lua
local Observable = Modules.Observable
local obs = Observable.new(0)
obs.Changed:Connect(function(v) print("changed:", v) end)
obs:set(5)
```

### GeometryUtil

```lua
local Geo = Modules.GeometryUtil
local minV, maxV = Geo.aabbFromPoints({ Vector3.new(), Vector3.new(1,2,3) })
```

### EasingUtil

```lua
local Ease = Modules.EasingUtil
-- Sample a few easings at t=0.5
local t = 0.5
print(Ease.linear(t))
```

### DeepTableUtil

```lua
local DT = Modules.DeepTableUtil
local merged = DT.deepMerge({ a = { x = 1 } }, { a = { y = 2 } })
```

### StatUtil

```lua
local Stat = Modules.StatUtil
local run = Stat.Running()
run.push(3); run.push(5)
print("mean=", run.mean())
```

### HashUtil

```lua
local Hash = Modules.HashUtil
print(Hash.stringHash("abc"))
```

### LRUCache

```lua
local LRU = Modules.LRUCache
local lru = LRU.new(100)
lru:set("k","v")
print(lru:get("k"))
```

### Memoize

```lua
local Memoize = Modules.Memoize
local square, cache = Memoize.wrap(function(x) return x*x end, { capacity = 100 })
print(square(5))
```

### EventBus

```lua
local Bus = Modules.EventBus
local bus = Bus.new()
local sub = bus:subscribe("topic", function(p) print("got", p) end)
bus:publish("topic", 123)
sub:Disconnect()
```

### Deque

```lua
local Deque = Modules.Deque
local dq = Deque.new()
dq:pushRight(1); dq:pushLeft(0)
print(dq:popLeft())
```

### PriorityQueue

```lua
local PQ = Modules.PriorityQueue
local pq = PQ.new()
pq:push(3); pq:push(1); pq:push(2)
print(pq:pop())
```

<a id="client-per-module-examples"></a>
## Client per-module examples

Require once on the client:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Client = require(ReplicatedStorage.UsefulFunctionsClient)
```

### CameraUtil

```lua
local cam = workspace.CurrentCamera
Client.CameraUtil.setSubject(nil) -- free camera (subject nil)
Client.CameraUtil.tweenTo(CFrame.new(0, 20, 0), TweenInfo.new(0.5))
Client.CameraUtil.shake(0.3, 1.0, 12)
```

### NotificationUtil

```lua
Client.NotificationUtil.show("Saved!", { duration = 1.5, stroke = true })
```

### NotificationQueue

```lua
local q = Client.NotificationQueue.new({ maxVisible = 3 })
q:enqueue("First")
q:enqueue("Second", { duration = 3 })
```

### ModalUtil

```lua
Client.ModalUtil.confirm({
	title = "Confirm",
	message = "Proceed?",
	buttons = { "Yes", "No" },
}):andThen(function(choice)
	print("You chose:", choice)
end)
```

### ClientRateLimiter

```lua
local limiter = Client.ClientRateLimiter.new(4, 2) -- cap 4, 2 tokens/s
local ok = limiter:allow("shoot")
```

### ProgressBar

```lua
local bar = Client.ProgressBar.create(script.Parent, { position = UDim2.fromScale(0.5, 0.9) })
bar:SetProgress(0.25, 0.2)
bar:SetText("Loading 25%")
```

### InputUtil

```lua
local unbind = Client.InputUtil.bindAction("Toggle", function()
	print("action")
end, true, { Enum.KeyCode.F })

Client.InputUtil.onKey(Enum.KeyCode.E, function(pressed)
	if pressed then print("E down") end
end)
```

### DeviceUtil

```lua
print("platform:", Client.DeviceUtil.platform())
print("viewport:", Client.DeviceUtil.viewport())
```

### ScreenFadeUtil

```lua
Client.ScreenFadeUtil.fadeIn(0.25, Color3.new(0,0,0))
task.wait(0.3)
Client.ScreenFadeUtil.fadeOut(0.25)
```

### GuiDragUtil

```lua
local stop = Client.GuiDragUtil.attach(someFrame, { clampToScreen = true })
-- later: stop()
```

### ViewportUtil

```lua
local vpf = Client.ViewportUtil.createViewport(UDim2.fromOffset(200, 200), Color3.new(0,0,0))
vpf.Parent = script.Parent
Client.ViewportUtil.setModel(vpf, workspace:WaitForChild("StarterCharacter"), { distance = 8 })
```

### CursorUtil

```lua
Client.CursorUtil.setIcon("rbxassetid://123")
Client.CursorUtil.lockCenter(true)
```

### ScreenShakeUtil

```lua
local stopShake = Client.ScreenShakeUtil.start({ amplitude = 1, frequency = 10, duration = 0.5 })
```

### HighlightUtil

```lua
local hl, cleanup = Client.HighlightUtil.show(workspace.Part, { color = Color3.new(1,0,0), duration = 2 })
-- cleanup() to remove immediately
```

### TooltipUtil

```lua
local un = Client.TooltipUtil.bind(someButton, { text = "Click me", delay = 0.2 })
```

### HapticUtil

```lua
Client.HapticUtil.rumble(Enum.UserInputType.Gamepad1, 0.7, 0.2)
```

### ScreenResizeUtil

```lua
local conn = Client.ScreenResizeUtil.onResize(function(size)
	print("new viewport:", size)
end)
```

### CursorRayUtil

```lua
local hit = Client.CursorRayUtil.raycastMouse()
if hit then print(hit.Instance) end
```

### ButtonFXUtil

```lua
local off = Client.ButtonFXUtil.bind(someButton, { hoverScale = 1.05, pressScale = 0.95 })
```

### LayoutUtil

```lua
Client.LayoutUtil.createList({ parent = someContainer, padding = UDim.new(0, 6) })
Client.LayoutUtil.createPadding({ parent = someContainer, left = UDim.new(0,8), right = UDim.new(0,8) })
```

### KeybindHintUtil

```lua
local id = Client.KeybindHintUtil.show({ key = "E", text = "Interact" })
-- later: Client.KeybindHintUtil.remove(id)
```

### TouchGestureUtil

```lua
local ctl = Client.TouchGestureUtil.bind({ minPinch = 0.02 })
ctl.OnPan = function(delta) print("pan:", delta) end
ctl.OnPinch = function(scale) print("pinch:", scale) end
-- ctl:Destroy() to unbind
```

### OffscreenIndicatorUtil

```lua
local stopInd = Client.OffscreenIndicatorUtil.attach(workspace.Target, { margin = 16 })
```

### ScrollUtil

```lua
Client.ScrollUtil.smoothScrollTo(someScrollingFrame, Vector2.new(0, 200), TweenInfo.new(0.3))
```

### SliderUtil

```lua
local slider = Client.SliderUtil.create({ parent = script.Parent, width = 200, initial = 0.5 })
slider.OnChanged:Connect(function(v) print("value:", v) end)
slider:SetValue(0.75)
```

<a id="server-per-module-examples"></a>
## Server per-module examples

Require once on the server:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
```

### TeleportUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local spawn = workspace:WaitForChild("SpawnLocation")
	Server.TeleportUtil.teleportInServer(p, spawn, { unseat = true })
end)
```

### MatchmakingUtil

```lua
local mm = Server.MatchmakingUtil.new(game.PlaceId, 2)
game.Players.PlayerAdded:Connect(function(p) mm:enqueue(p) end)
mm:onMatched(function(players) print("matched:", #players) end)
```

### HttpUtil

```lua
local ok, json = Server.HttpUtil.fetchJson("https://httpbin.org/json")
if ok then print(json.slideshow and json.slideshow.title) end
```

### DataStoreUtil

```lua
local store = Server.DataStoreUtil.getStore("UF_Data")
local key = "p:"..game.PrivateServerId
local ok, value = Server.DataStoreUtil.increment(store, key, 1)
```

### LeaderstatsUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.LeaderstatsUtil.addInt(p, "Coins", 0)
	Server.LeaderstatsUtil.increment(p, "Coins", 1)
end)
```

### MessagingServiceUtil

```lua
local sub = Server.MessagingServiceUtil.subscribe("uf:news", function(data)
	print("news:", data)
end)
Server.MessagingServiceUtil.publish("uf:news", { hello = true })
```

### MemoryStoreUtil

```lua
local q = Server.MemoryStoreUtil.queue("jobs")
q.enqueue({ task = "do" }, 60)
local ok, entries = q.tryDequeue(1, 2)
if ok and #entries > 0 then q.complete(entries[1]) end

local map = Server.MemoryStoreUtil.map("counters")
map.increment("hits", 1, 300)
```

### BadgeUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.BadgeUtil.awardIfNotOwned(p, 123456)
end)
```

### GroupUtil

```lua
local rank = Server.GroupUtil.getRankInGroup(12345678, 9876543)
print("rank:", rank)
```

### MarketplaceUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local ok, owns = Server.MarketplaceUtil.ownsGamePass(p, 123)
	if not owns then Server.MarketplaceUtil.promptGamePass(p, 123) end
end)
```

### PolicyUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	print("voice enabled:", Server.PolicyUtil.isVoiceEnabled(p))
end)
```

### BanUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local should, msg = Server.BanUtil.shouldKick(p)
	if should then p:Kick(msg) end
end)
```

### WebhookUtil

```lua
Server.WebhookUtil.postJson("https://example.com/webhook", { hello = "world" })
```

### ChatFilterUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local ok, clean = Server.ChatFilterUtil.filterForBroadcast("hi", p.UserId)
	if ok then print(clean) end
end)
```

### AccessControlUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local allowed, reason = Server.AccessControlUtil.canUseFeature(p, {
		group = { id = 123456, minRank = 50 },
		requireVoice = true,
	})
	if not allowed then warn("blocked:", reason) end
end)
```

### JobScheduler

```lua
local sched = Server.JobScheduler.new("uf-jobs", { visibility = 30, poll = 1 })
sched:startWorker(function(payload)
	print("job:", payload.task)
end)
sched:enqueue({ task = "ping" }, 60)
```

### AuditLogUtil

```lua
local log = Server.AuditLogUtil.new("https://example.com/log", { batchSize = 10, flushInterval = 5 })
log:log("player_join", { userId = 123 })
log:start()
```

### CharacterScaleUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.CharacterScaleUtil.tweenUniformScale(p, 1.1, TweenInfo.new(0.4))
end)
```

### CharacterMovementUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.CharacterMovementUtil.tempWalkSpeed(p, 28, { mode = "set", duration = 5 })
end)
```

### CharacterAppearanceUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.CharacterAppearanceUtil.setBodyColors(p, { Torso = Color3.fromRGB(255, 200, 150) })
end)
```

### CharacterVisibilityUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	Server.CharacterVisibilityUtil.setInvisible(p, true, { nonCollide = true })
	task.delay(2, function()
		Server.CharacterVisibilityUtil.setInvisible(p, false)
	end)
end)
```

### CharacterHealthUtil

```lua
game.Players.PlayerAdded:Connect(function(p)
	local ok, disable = Server.CharacterHealthUtil.setInvulnerable(p, true, { duration = 3 })
end)
```

<a id="shared-modules"></a>
## Shared modules

All available from the Shared bundle (`Modules.X`).

<a id="signal--lightweight-events"></a>
### Signal — lightweight events
- new() -> Signal
- Signal:Connect(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Once(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Fire(...: any)
- Signal:Wait() -> ...any
- Signal:Destroy()
- Example: `local sig = Modules.Signal.new(); local c = sig:Connect(print); sig:Fire("hi")`

<a id="maid--cleanup-aggregator"></a>
### Maid — cleanup aggregator
- new() -> Maid
- Maid:GiveTask(task: Instance|RBXScriptConnection|() -> ())
- Maid:Cleanup()
- Maid:DoCleaning() -- alias
- Maid:Destroy()
- Example: `local m = Modules.Maid.new(); m:GiveTask(conn); m:Cleanup()`

<a id="debounce--debouncethrottle"></a>
### Debounce — debounce/throttle
- debounce(fn: (...any) -> (), waitSeconds: number) -> (...any) -> ()
- throttle(fn: (...any) -> (), intervalSeconds: number) -> (...any) -> ()

<a id="timer--tiny-scheduler"></a>
### Timer — tiny scheduler
- wait(seconds: number)
- setTimeout(fn: () -> (), delaySeconds: number) -> { Stop: () -> () }
- setInterval(fn: () -> (), intervalSeconds: number) -> { Stop: () -> () }

<a id="tweenutil--tween-numbersprops"></a>
### TweenUtil — tween numbers/props
- tween(target: Instance|number, info: TweenInfo, goalOrOnStep: table|((number)->())) -> Tween? 
- tweenAsync(instance: Instance, info: TweenInfo, goalProps: { [string]: any }) -> (boolean, string?)
- sequence(instance: Instance, steps: { {info: TweenInfo, goal: {[string]: any}, yield: boolean?} }) -> boolean

<a id="instanceutil--instance-helpers"></a>
### InstanceUtil — instance helpers
- create(className: string, props?: table, children?: {Instance}) -> Instance
- getOrCreate(parent: Instance, className: string, name?: string) -> Instance
- waitForDescendant(parent: Instance, name: string, timeoutSeconds?: number) -> Instance?
- destroyChildren(parent: Instance, predicate?: (Instance) -> boolean)
- cloneInto(source: Instance, parent: Instance, props?: table) -> Instance

<a id="tableutil--table-helpers"></a>
### TableUtil — table helpers
- copy(t: any, deep?: boolean) -> any
- assign(target: table, ...) -> table
- mergeDeep(target: table, ...) -> table
- equals(a: any, b: any, deep?: boolean) -> boolean
- map(list: table, fn: (any, number) -> any) -> table
- filter(list: table, fn: (any, number) -> boolean) -> table
- find(list: table, fn: (any, number) -> boolean) -> any
- keys(t: table) -> table; values(t: table) -> table; isArray(t: any) -> boolean

<a id="stringutil--string-helpers"></a>
### StringUtil — string helpers
- ltrim(s: string) -> string; rtrim(s: string) -> string; trim(s: string) -> string
- split(s: string, sep: string, plain?: boolean) -> {string}; join(list: {string}, sep: string) -> string
- startsWith(s: string, prefix: string) -> boolean; endsWith(s: string, suffix: string) -> boolean
- capitalize(s: string) -> string; toTitleCase(s: string) -> string
- padLeft(s: string, len: number, ch?: string) -> string; padRight(s: string, len: number, ch?: string) -> string
- slugify(s: string) -> string; formatThousands(n: number) -> string

<a id="formatutil--formatting-helpers"></a>
### FormatUtil — formatting helpers
- withCommas(n: number) -> string
- abbreviate(n: number, decimals?: number) -> string
- percent(n: number, decimals?: number) -> string
- bytes(n: number, decimals?: number) -> string
- timeAgo(seconds: number) -> string

<a id="mathutil--math-helpers"></a>
### MathUtil — math helpers
- clamp(n, minV, maxV) -> number; lerp(a, b, t) -> number; invLerp(a, b, v) -> number
- remap(v, inMin, inMax, outMin, outMax, doClamp?) -> number
- round(n, decimals?) -> number; roundTo(n, increment) -> number; floorTo(n, increment) -> number; ceilTo(n, increment) -> number
- approxEqual(a, b, eps?) -> boolean; randomRange(min, max, integer?) -> number
- chooseWeighted(entries: { {item:any, weight:number} }) -> any

<a id="cframeutil--cframe-helpers"></a>
### CFrameUtil — CFrame helpers
- lookAt(origin: Vector3, target: Vector3, up?: Vector3) -> CFrame
- fromYawPitchRoll(y, p, r) -> CFrame; toYawPitchRoll(cf: CFrame) -> (number, number, number)
- rotateAround(cf: CFrame, origin: Vector3, axisUnit: Vector3, radians: number) -> CFrame
- offset(cf: CFrame, delta: Vector3) -> CFrame; clampYaw(cf: CFrame, minYaw: number, maxYaw: number) -> CFrame

<a id="vectorutil--vector3-helpers"></a>
### VectorUtil — Vector3 helpers
- clampMagnitude(v: Vector3, max: number) -> Vector3; horizontal(v) -> Vector3
- distance(a, b) -> number; distanceXZ(a, b) -> number
- project(a, onto) -> Vector3; reject(a, onto) -> Vector3; angleBetween(a, b) -> number
- fromYawPitch(yaw, pitch) -> Vector3; approximately(a, b, eps?) -> boolean; lerp(a, b, t) -> Vector3

<a id="raycastutil--raycast-helpers"></a>
### RaycastUtil — raycast helpers
- params(list?: {Instance}, mode?: "Include"|"Exclude") -> RaycastParams
- ignoreCharacter(params: RaycastParams, who: Player|Model|Humanoid)
- raycast(origin: Vector3, direction: Vector3, params?: RaycastParams) -> RaycastResult?
- raycastFromTo(a: Vector3, b: Vector3, params?: RaycastParams) -> RaycastResult?
- ground(position: Vector3, maxDistance?: number, params?: RaycastParams) -> RaycastResult?

<a id="colorutil--color3-helpers"></a>
### ColorUtil — Color3 helpers
- fromHex(hex: string) -> Color3; toHex(c: Color3) -> string
- fromRGB(r,g,b) -> Color3; toRGB(c: Color3) -> (number, number, number)
- lerp(a: Color3, b: Color3, t: number) -> Color3; lighten(c: Color3, factor: number) -> Color3; darken(c: Color3, factor: number) -> Color3

<a id="collectionutil--collectionservice-tags"></a>
### CollectionUtil — CollectionService tags
- addTag(inst: Instance, tag: string)
- removeTag(inst: Instance, tag: string)
- hasTag(inst: Instance, tag: string) -> boolean
- getTagged(tag: string) -> {Instance}
- onAdded(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- onRemoved(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- watchTag(tag: string, onAdded: (Instance)->(), onRemoved?: (Instance)->()) -> () -> ()

<a id="timeutil--time-formatting"></a>
### TimeUtil — time formatting
- nowUnix() -> number; formatDuration(seconds: number) -> string; humanize(seconds: number) -> string
- iso8601(epoch?: number) -> string; localISO(epoch?: number) -> string

<a id="patternutil--lua-pattern-utils"></a>
### PatternUtil — Lua pattern utils
- escapePattern(s: string) -> string
- findAll(s: string, pattern: string, init?: number) -> { [number]: { start:number, finish:number, captures:{any} } }
- matchAll(s: string, pattern: string) -> {any}
- replace(s: string, pattern: string, repl: any, n?: number) -> (string, number)
- count(s: string, pattern: string) -> number
- splitByPattern(s: string, pattern: string) -> {string}
- startsWithPattern(s: string, pattern: string) -> boolean; endsWithPattern(s: string, pattern: string) -> boolean
- wildcardToPattern(glob: string) -> string

<a id="promiseutil--promises"></a>
### PromiseUtil — Promises
- Promise.new(executor)
- :isSettled(); :andThen(onFulfilled?, onRejected?); :catch(onRejected); :finally(onFinally)
- resolve(value); reject(reason); delay(seconds, value?); all(list); race(list); timeout(promiseOrFn, seconds, timeoutErr?); retry(fn, attempts?, backoff?)

<a id="playerutil--playercharacter"></a>
### PlayerUtil — player/character
- getPlayerFromCharacter(model: Instance) -> Player?
- getHumanoid(target: any) -> Humanoid?; getHRP(target: any) -> BasePart?
- waitForCharacter(player: Player, timeout?: number) -> Model?
- waitForHumanoid(target: Player|Model, timeout?: number) -> Humanoid?
- waitForHRP(target: Player|Model, timeout?: number) -> BasePart?
- isAlive(target: any) -> boolean

<a id="soundutil--sound-helpers"></a>
### SoundUtil — sound helpers
- preload(list: {Sound|string|number})
- play(soundOrId: Sound|string|number, opts: { parent?: Instance, volume?: number, looped?: boolean, pitch?: number }) -> (Sound, { Stop: ()->(), FadeOut: (seconds:number)->() })

<a id="randomutil--rng-convenience"></a>
### RandomUtil — RNG convenience
- new(seed?: number) -> RNG
- RNG:integer(min: number, max: number) -> number; RNG:number(min, max) -> number
- RNG:choice(list: {any}) -> any?; RNG:shuffle(list: {any}, inPlace?: boolean) -> {any}
- RNG:sample(list: {any}, k: number, unique?: boolean) -> {any}
- RNG:weighted(entries: { {item:any, weight:number} }) -> any
- RNG:bag(items: {any}) -> () -> any -- bag sampler

<a id="ratelimiter--token-bucket"></a>
### RateLimiter — token bucket
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)
- Limiter:setCapacity(n: number); Limiter:setRefillPerSecond(n: number); Limiter:getState(key: string) -> { tokens:number, updated:number }

<a id="statemachine--finite-state-machine"></a>
### StateMachine — finite state machine
- new(initial: string) -> FSM
- FSM:addState(name: string, def?: { onEnter?: (prev?, data?) -> (), onExit?: (next?, data?) -> () })
- FSM:can(target: string) -> boolean; FSM:transition(target: string, data?: any)
- FSM:destroy()

<a id="cooldownutil--per-key-cooldowns"></a>
### CooldownUtil — per-key cooldowns
- new(defaultDuration: number) -> CD
- CD:set(key: string, duration?: number)
- CD:timeRemaining(key: string) -> number
- CD:canUse(key: string) -> boolean; CD:use(key: string) -> boolean; CD:clear(key: string)

<a id="cacheutil--ttl-cache"></a>
### CacheUtil — TTL cache
- new(defaultTtlSeconds?: number, maxSize?: number) -> Cache
- Cache:set(key: string, value: any, ttlSeconds?: number)
- Cache:get(key: string) -> any
- Cache:getOrCompute(key: string, producer: () -> any, ttlSeconds?: number) -> any
- Cache:delete(key: string); Cache:clear(); Cache:size() -> number

<a id="uuidutil--idsstrings"></a>
### UUIDUtil — ids/strings
- guid() -> string; randomString(length?: number, charset?: string) -> string; shortId(length?: number) -> string

<a id="observable--reactive-value"></a>
### Observable — reactive value
- new(initial: any) -> Observable
- Observable:get() -> any; Observable:set(v: any)
- Observable.Changed (Signal); Observable:Destroy()

<a id="geometryutil--geometry-helpers"></a>
### GeometryUtil — geometry helpers
- aabbFromPoints(points: {Vector3}) -> (Vector3 min, Vector3 max)
- aabbToCFrameSize(minV: Vector3, maxV: Vector3) -> (CFrame, Vector3 size)
- aabbFromInstance(inst: Instance) -> (Vector3 min, Vector3 max)
- rayPlaneIntersection(rayOrigin: Vector3, rayDir: Vector3, planePoint: Vector3, planeNormal: Vector3) -> Vector3?
- closestPointOnSegment(a: Vector3, b: Vector3, p: Vector3) -> Vector3
- pointInTriangle2D(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> boolean

<a id="easingutil--easing-curves"></a>
### EasingUtil — easing curves
- linear(t)
- quad/cubic/quart/quint In|Out|InOut(t)
- sine In|Out|InOut(t); expo/circ/back/bounce/elastic variants

<a id="deeptableutil--deep-ops"></a>
### DeepTableUtil — deep ops
- deepClone(t) -> any; deepMerge(dest, src) -> any
- getIn(t, path: {any}, default: any?) -> any; setIn(t, path: {any}, value: any) -> any
- equalsDeep(a, b) -> boolean

<a id="statutil--stats-helpers"></a>
### StatUtil — stats helpers
- ema(prev: number?, x: number, alpha: number) -> number
- Running() -> { push: (number)->(), mean: ()->number, min: number, max: number, count: number }

<a id="hashutil--hashes"></a>
### HashUtil — hashes
- stringHash(s: string) -> number; stableHash(value: any) -> number

<a id="lrucache--lru-map-with-ttl"></a>
### LRUCache — LRU map with TTL
- new(capacity: number) -> LRU
- LRU:set(key: any, value: any, ttlSeconds?: number)
- LRU:get(key: any) -> any
- LRU:delete(key: any); LRU:clear(); LRU:len() -> number

<a id="memoize--memoize-wrapper"></a>
### Memoize — memoize wrapper
- wrap(fn: (...any)->any, options: { capacity?: number, ttl?: number }) -> (memoizedFn: (...any)->any, cache: LRUCache)

<a id="eventbus--pubsub"></a>
### EventBus — pub/sub
- new() -> Bus
- Bus:subscribe(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:publish(topic: string, ...: any)
- Bus:once(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:hasSubscribers(topic: string) -> boolean
- Bus:Destroy()

<a id="deque--double-ended-queue"></a>
### Deque — double-ended queue
- new() -> Deque
- Deque:pushLeft(v); Deque:pushRight(v); Deque:popLeft() -> any; Deque:popRight() -> any
- Deque:peekLeft() -> any; Deque:peekRight() -> any; Deque:clear(); Deque:len() -> number

<a id="priorityqueue--min-heap"></a>
### PriorityQueue — min-heap
- new(lessFn?: (a:any,b:any)->boolean) -> PQ
- PQ:push(v); PQ:pop() -> any; PQ:peek() -> any; PQ:len() -> number

---

<a id="client-modules"></a>
## Client modules

All available from the Client bundle (`Client.X`).

<a id="camerautil--camera-helpers"></a>
### CameraUtil — camera helpers
- setSubject(subject?: Instance)
- tweenTo(cf: CFrame, info: TweenInfo, focus?: Vector3)
- shake(duration: number, magnitude?: number, frequency?: number)

<a id="notificationutil--quick-toasts"></a>
### NotificationUtil — quick toasts
- show(text: string, opts: { duration?: number, stroke?: boolean, position?: UDim2, anchor?: Vector2 })

<a id="notificationqueue--queuedstacked-toasts"></a>
### NotificationQueue — queued/stacked toasts
- new(opts?: { maxVisible?: number, gap?: number, position?: UDim2, anchor?: Vector2 }) -> Queue
- Queue:destroy(); Queue:setMaxVisible(n: number); Queue:setGap(px: number)
- Queue:setPosition(pos: UDim2, anchor?: Vector2); Queue:clear()
- Queue:show(text: string, opts?); Queue:enqueue(text: string, opts?)

<a id="modalutil--confirm-dialogs"></a>
### ModalUtil — confirm dialogs
- confirm(opts: { title?: string, message?: string, buttons?: {string} }) -> Promise<string>

<a id="clientratelimiter--client-side-limiter"></a>
### ClientRateLimiter — client-side limiter
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)

<a id="progressbar--simple-progress-ui"></a>
### ProgressBar — simple progress UI
- create(parent?: Instance, opts?: { size?: UDim2, position?: UDim2, corner?: number, theme?: {bg:Color3, fill:Color3, text:Color3} }) -> Bar
- Bar:SetProgress(alpha: number, tweenSeconds?: number)
- Bar:SetText(text?: string); Bar:Show(); Bar:Hide(); Bar:Destroy()

<a id="inpututil--input-helpers"></a>
### InputUtil — input helpers
- bindAction(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- bindOnce(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- onKey(keyCode: Enum.KeyCode, fn: (pressed:boolean)->()) -> RBXScriptConnection
- isTouch() -> boolean; isGamepad() -> boolean; isKeyboardMouse() -> boolean

<a id="deviceutil--device-info"></a>
### DeviceUtil — device info
- viewport() -> Vector2; platform() -> string; isSmallScreen() -> boolean; safeAreaInset() -> Vector2

<a id="screenfadeutil--fade-overlay"></a>
### ScreenFadeUtil — fade overlay
- fadeIn(duration: number, color?: Color3, transparency?: number)
- fadeOut(duration: number)
- flash(duration: number)

<a id="guidragutil--draggable-frames"></a>
### GuiDragUtil — draggable frames
- attach(frame: GuiObject, opts?: { clampToScreen?: boolean, sensitivity?: number }) -> ()->()

<a id="viewportutil--viewportframe-helpers"></a>
### ViewportUtil — ViewportFrame helpers
- createViewport(size: UDim2, bg?: Color3) -> ViewportFrame
- setModel(vpf: ViewportFrame, model: Model, opts?: { cameraCFrame?: CFrame, distance?: number })

<a id="cursorutil--mouse-cursor"></a>
### CursorUtil — mouse cursor
- show(); hide(); setIcon(icon: string)
- lockCenter(enable: boolean); isLocked() -> boolean

<a id="screenshakeutil--camera-shake"></a>
### ScreenShakeUtil — camera shake
- start(params: { amplitude: number, frequency: number, duration: number, decay?: boolean }) -> ()->()

<a id="highlightutil--highlight-partsmodels"></a>
### HighlightUtil — highlight parts/models
- show(target: Instance, options?: { color?: Color3, fill?: number, outline?: number, duration?: number }) -> (Highlight, ()->())

<a id="tooltiputil--hover-tooltips"></a>
### TooltipUtil — hover tooltips
- bind(guiObject: GuiObject, options: { text: string, delay?: number, offset?: Vector2 }) -> ()->()

<a id="hapticutil--gamepad-rumble"></a>
### HapticUtil — gamepad rumble
- rumble(gamepad: Enum.UserInputType, intensity: number, duration: number)
- rumbleAll(intensity: number, duration: number)

<a id="screenresizeutil--viewport-size-changes"></a>
### ScreenResizeUtil — viewport size changes
- onResize(handler: (Vector2)->()) -> RBXScriptConnection
- getViewportSize() -> Vector2

<a id="cursorrayutil--screen-to-worldraycast"></a>
### CursorRayUtil — screen-to-world/raycast
- screenPointToRay(point: Vector2, depth?: number) -> (Vector3 origin, Vector3 direction)
- mouseRay(depth?: number) -> (Vector3 origin, Vector3 direction)
- raycastFromScreenPoint(point: Vector2, params?: RaycastParams) -> RaycastResult?
- raycastMouse(params?: RaycastParams) -> RaycastResult?
- worldPointFromScreen(point: Vector2, depth: number) -> Vector3
- worldPointFromMouse(depth: number) -> Vector3

<a id="buttonfxutil--hoverpress-scale-fx"></a>
### ButtonFXUtil — hover/press scale FX
- bind(button: GuiObject, options?: { hoverScale?: number, pressScale?: number, tween?: TweenInfo }) -> ()->()

<a id="layoututil--ui-layout-builders"></a>
### LayoutUtil — UI layout builders
- createList(options?: { parent?: Instance, padding?: UDim, fill?: boolean, align?: Enum.HorizontalAlignment }) -> UIListLayout
- createGrid(options?: { parent?: Instance, cellSize?: UDim2, cellPadding?: UDim2 }) -> UIGridLayout
- createTable(options?: { parent?: Instance, padding?: UDim }) -> UITableLayout
- createPadding(options?: { parent?: Instance, left?: UDim, right?: UDim, top?: UDim, bottom?: UDim }) -> UIPadding

<a id="keybindhintutil--keybind-hints"></a>
### KeybindHintUtil — keybind hints
- show(options: { key: string, text: string, position?: UDim2 }) -> string|number
- remove(id: string|number)

<a id="touchgestureutil--panpinchrotate"></a>
### TouchGestureUtil — pan/pinch/rotate
- bind(options?: { minPinch?: number, minRotate?: number }) -> Controller
- Controller.OnPan(delta: Vector2); Controller.OnPinch(delta: number); Controller.OnRotate(radians: number)
- Controller:Destroy()

<a id="offscreenindicatorutil--edge-arrows"></a>
### OffscreenIndicatorUtil — edge arrows
- attach(target: Instance, options?: { margin?: number, color?: Color3 }) -> ()->()

<a id="scrollutil--smooth-scroll"></a>
### ScrollUtil — smooth scroll
- smoothScrollTo(scroller: ScrollingFrame, target: Vector2, tweenInfo?: TweenInfo)
- scrollBy(scroller: ScrollingFrame, dx: number, dy: number, tweenInfo?: TweenInfo)

<a id="sliderutil--horizontal-slider"></a>
### SliderUtil — horizontal slider
- create(options: { parent?: Instance, width?: number, initial?: number }) -> Slider
- Slider.OnChanged(value: number) (Signal); Slider:SetValue(value: number)

---

<a id="server-modules"></a>
## Server modules

All available from the Server bundle (`Server.X`).

<a id="teleportutil--teleports"></a>
### TeleportUtil — teleports
- teleportInServer(target: Player|Model, destination: CFrame|Vector3|BasePart, options?: { keepOrientation?: boolean, offset?: Vector3, unseat?: boolean }) -> boolean
- teleportToPlace(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- teleportToPlaceInstance(placeId: number, jobId: string, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- reserveServer(placeId: number) -> (string accessCode, string reservedServerId)
- teleportToPrivateServer(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean ok, string? errMsg, string? accessCode)

<a id="matchmakingutil--queueparty-matching"></a>
### MatchmakingUtil — queue/party matching
- new(placeId: number, partySize: number, opts?: { retries?: number, backoff?: number, pollSeconds?: number }) -> MM
- MM:onMatched(cb: ({Player})->()) -> RBXScriptConnection
- MM:enqueue(player: Player); MM:dequeue(player: Player); MM:size() -> number; MM:flush(); MM:destroy()

<a id="httputil--http-requests"></a>
### HttpUtil — HTTP requests
- request(opts: { method: string, url: string, headers?: table, body?: string|table, json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res: { StatusCode: number, Success: boolean, Headers: table, Body: string, Json?: any }?, err?: string)
- get(url: string, headers?: table, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- post(url: string, body: any, headers?: table, opts?: { json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- fetchJson(url: string, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, json?: any, err?: string)
- encode(value: any) -> string; decode(str: string) -> any

<a id="datastoreutil--datastore-helpers"></a>
### DataStoreUtil — DataStore helpers
- getStore(name: string, scope?: string) -> DataStore
- waitForBudget(type: Enum.DataStoreRequestType, min?: number, timeout?: number) -> boolean
- get(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, value?: any, err?: string)
- set(store: GlobalDataStore, key: string, value: any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)
- update(store: GlobalDataStore, key: string, fn: (old:any)->any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: any, err?: string)
- increment(store: GlobalDataStore, key: string, delta: number, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: number, err?: string)
- remove(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)

<a id="leaderstatsutil--leaderstats"></a>
### LeaderstatsUtil — leaderstats
- addNumber(player: Player, name: string, initial?: number) -> NumberValue
- addInt(player: Player, name: string, initial?: number) -> IntValue
- addString(player: Player, name: string, initial?: string) -> StringValue
- get(player: Player, name: string) -> ValueBase?
- getNumber(player: Player, name: string) -> number?
- set(player: Player, name: string, value: any) -> ValueBase
- increment(player: Player, name: string, delta?: number) -> number
- bindAutoSetup(Players: Players) -> ()->()  
	Creates a `leaderstats` folder for all players and on join; returns disconnect function.
- attachPersistence(store: GlobalDataStore, keyFn: (player: Player)->string) -> { load: (Player)->(boolean, string?), save: (Player)->(boolean, string?) }

<a id="messagingserviceutil--pubsub"></a>
### MessagingServiceUtil — pub/sub
- publish(topic: string, data: any, opts?: { retries?: number, backoff?: number }) -> (boolean, any)
- subscribe(topic: string, handler: (data:any, message:any)->(), opts?: { safe?: boolean }) -> { Disconnect: ()->() }

<a id="memorystoreutil--queuesmaps"></a>
### MemoryStoreUtil — queues/maps
- queue(name: string) -> Queue
	- Queue.enqueue(item: any, ttl?: number) -> (boolean, any)
	- Queue.tryDequeue(count?: number, waitTimeout?: number) -> (boolean, { entries: { { Id: string, Value: any } } }|string)
	- Queue.complete(entry: { Id: string, Value: any }) -> (boolean, any)
- map(name: string) -> Map
	- Map.get(key: string) -> (boolean, any)
	- Map.set(key: string, value: any, expiration?: number) -> (boolean, any)
	- Map.increment(key: string, delta?: number, expiration?: number) -> (boolean, number|any)

<a id="badgeutil--badges"></a>
### BadgeUtil — badges
- hasBadge(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, boolean|any)
- awardIfNotOwned(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, any)

<a id="grouputil--group-info"></a>
### GroupUtil — group info
- getRoleInGroup(userIdOrPlayer: number|Player, groupId: number) -> (string?|nil, string?|nil)
- getRankInGroup(userIdOrPlayer: number|Player, groupId: number) -> (number, string?|nil)
- isInGroup(userIdOrPlayer: number|Player, groupId: number, minRank?: number) -> boolean

<a id="marketplaceutil--purchases"></a>
### MarketplaceUtil — purchases
- ownsGamePass(player: Player, gamePassId: number) -> (boolean, boolean|any)
- promptGamePass(player: Player, gamePassId: number)
- promptProduct(player: Player, productId: number)
- createReceiptRouter(map: { [productId: number]: (player: Player, receiptInfo: any) -> Enum.ProductPurchaseDecision }) -> (receiptInfo: any) -> Enum.ProductPurchaseDecision
- bindProcessReceipt(fn: (receiptInfo: any) -> Enum.ProductPurchaseDecision)

<a id="policyutil--policy-checks"></a>
### PolicyUtil — policy checks
- getPolicy(player: Player) -> (table?|nil, string?|nil)
- arePaidRandomItemsRestricted(player: Player) -> boolean?|nil
- isSubjectToChinaPolicies(player: Player) -> boolean?|nil
- isVoiceEnabled(player: Player) -> boolean?|nil

<a id="banutil--bans"></a>
### BanUtil — bans
- ban(userIdOrPlayer: number|Player, reason?: string, durationSeconds?: number, by?: string) -> (boolean, any)
- unban(userIdOrPlayer: number|Player) -> (boolean, any)
- getBan(userIdOrPlayer: number|Player) -> ({ reason?: string, expiresAt?: number, by?: string }?|nil, any)
- isBanned(userIdOrPlayer: number|Player) -> boolean
- shouldKick(player: Player) -> (boolean, string?)

<a id="webhookutil--json-webhooks"></a>
### WebhookUtil — JSON webhooks
- postJson(url: string, payload: table, opts?: { headers?: table, compress?: boolean, httpService?: HttpService }) -> (boolean, any)

<a id="chatfilterutil--text-filter"></a>
### ChatFilterUtil — text filter
- filterForBroadcast(text: string, fromUserId: number) -> (boolean, string|any)
- filterForUser(text: string, fromUserId: number, toUserId: number) -> (boolean, string|any)

<a id="accesscontrolutil--feature-gates"></a>
### AccessControlUtil — feature gates
- canUseFeature(player: Player, rules: { allowUserIds?: {number}, denyUserIds?: {number}, group?: { id: number, minRank?: number }, gamePassId?: number, requireVoice?: boolean, forbidPaidRandomItems?: boolean }, deps?: { PolicyUtil?: any, GroupUtil?: any, MarketplaceUtil?: any }) -> (boolean, string?)

<a id="jobscheduler--background-jobs"></a>
### JobScheduler — background jobs
- new(name: string, opts?: { visibility?: number, poll?: number }) -> Scheduler
- Scheduler:enqueue(payload: any, ttl?: number) -> (boolean, any)
- Scheduler:startWorker(handler: (payload: any, entry: { Id: string, Value: any })->())
- Scheduler:stopWorker()

<a id="auditlogutil--batched-logging"></a>
### AuditLogUtil — batched logging
- new(url: string, opts?: { batchSize?: number, flushInterval?: number }) -> Logger
- Logger:setDestination(url: string)
- Logger:log(eventName: string, fields?: table)
- Logger:start(); Logger:stop()

<a id="characterscaleutil--r15-scaling"></a>
### CharacterScaleUtil — R15 scaling
- getScales(target: Player|Model|Humanoid) -> { height: number, width: number, depth: number, head: number }
- setScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, options?: { clamp?: boolean }) -> (boolean, string?)
- setUniformScale(target: Player|Model|Humanoid, scale: number, options?: { clamp?: boolean }) -> (boolean, string?)
- tweenScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- tweenUniformScale(target: Player|Model|Humanoid, scale: number, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- reset(target: Player|Model|Humanoid) -> (boolean, string?)

<a id="charactermovementutil--movement-properties"></a>
### CharacterMovementUtil — movement properties
- get(target: Player|Model|Humanoid) -> { WalkSpeed: number, JumpPower?: number, JumpHeight?: number, AutoRotate: boolean, HipHeight: number, MaxSlopeAngle: number }|nil, string?
- set(target: Player|Model|Humanoid, props: table) -> (boolean, string?)
- setWalkSpeed(target: Player|Model|Humanoid, speed: number) -> (boolean, string?)
- setJumpPower(target: Player|Model|Humanoid, power: number) -> (boolean, string?)
- setJumpHeight(target: Player|Model|Humanoid, height: number) -> (boolean, string?)
- setAutoRotate(target: Player|Model|Humanoid, enabled: boolean) -> (boolean, string?)
- setHipHeight(target: Player|Model|Humanoid, height: number) -> (boolean, string?)
- tempWalkSpeed(target: Player|Model|Humanoid, value: number, options?: { mode?: "set"|"add"|"mul", duration?: number }) -> (boolean, ()->()|string)
- apply(target: Player|Model|Humanoid, props: table) -> (boolean, ()->()|string)

<a id="characterappearanceutil--outfitscolorsaccessories"></a>
### CharacterAppearanceUtil — outfits/colors/accessories
- applyDescription(target: Player|Model|Humanoid, description: HumanoidDescription) -> (boolean, string?)
- applyUserOutfit(target: Player|Model|Humanoid, userId: number) -> (boolean, string?)
- applyOutfitId(target: Player|Model|Humanoid, outfitId: number) -> (boolean, string?)
- setBodyColors(targetOrCharacter: Player|Model|Humanoid, colors?: { Head?: BrickColor|Color3|string, LeftArm?: BrickColor|Color3|string, RightArm?: BrickColor|Color3|string, LeftLeg?: BrickColor|Color3|string, RightLeg?: BrickColor|Color3|string, Torso?: BrickColor|Color3|string }) -> BodyColors|nil, string?
- addAccessory(target: Player|Model|Humanoid, accessory: Accessory) -> (boolean, string?)
- removeAccessories(target: Player|Model|Humanoid, predicate?: (Accessory)->boolean) -> (number|false, string?)
- setClothingIds(target: Player|Model|Humanoid, shirtId?: number|string, pantsId?: number|string) -> (boolean, string?)

<a id="charactervisibilityutil--transparencyghost"></a>
### CharacterVisibilityUtil — transparency/ghost
- setTransparency(target: Player|Model|Humanoid, alpha: number, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setInvisible(target: Player|Model|Humanoid, enabled: boolean, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setGhostMode(target: Player|Model|Humanoid, enabled: boolean) -> (boolean, string?)

<a id="characterhealthutil--healthinvulnerability"></a>
### CharacterHealthUtil — health/invulnerability
- setMaxHealth(target: Player|Model|Humanoid, maxHealth: number, options?: { clamp?: boolean }) -> (boolean, string?)
- heal(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- damage(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- setInvulnerable(target: Player|Model|Humanoid, enabled: boolean, options?: { duration?: number }) -> (boolean, (() -> ())?)

---

<a id="usage-notes"></a>
## Usage notes
- Prefer bundle requires; they export all modules as fields.
- Server-only modules must be required on the server.
- For practical examples, see `Tests/AllModules.client.lua` and `Tests/AllModules.server.lua`.
