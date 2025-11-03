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
local TeleportUtil = Modules.TeleportUtil
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

## Using with Rojo (recommended for GitHub repos)

This repo includes a minimal `default.project.json` so you can sync straight into Studio:

```json
{
	"name": "UsefulFunctions",
	"tree": {
		"$className": "DataModel",
		"ReplicatedStorage": {
			"UsefulFunctions": { "$path": "UsefulFunctions.lua" },
			"Modules": { "$path": "Modules" }
		}
	}
}
```

With that mapping, in Studio you can require:

```lua
local Modules = require(game.ReplicatedStorage.UsefulFunctions)
```

Alternatively, require modules directly:

```lua
local TeleportUtil = require(path.to.Modules.TeleportUtil)
```

## Modules

### Signal
- Lightweight event system wrapping BindableEvent.
- API: `Signal.new()`, `:Connect`, `:Once`, `:Fire`, `:Wait`, `:Destroy`.

```lua
local signal = Signal.new()
local conn = signal:Connect(function(msg) print("got", msg) end)
signal:Fire("hello")
conn:Disconnect()
signal:Destroy()
```

### Maid
- Cleanup manager for connections, instances, and functions.
- API: `Maid.new()`, `:GiveTask`, `:Cleanup`, `:Destroy`.

```lua
local maid = Maid.new()
maid:GiveTask(workspace.ChildAdded:Connect(function() end))
maid:GiveTask(function() print("cleanup") end)
maid:Cleanup() -- runs & disconnects all
```

### Debounce
- Debounce & throttle helpers.
- API: `debounce(fn, wait)`, `throttle(fn, interval)`.

```lua
local onResize = Debounce.debounce(function(w, h) print(w, h) end, 0.25)
onResize(800, 600)
```

### Timer
- Simple timers.
- API: `setTimeout(fn, delay)`, `setInterval(fn, interval)`, `wait(seconds)`.

```lua
Timer.setTimeout(function() print("once") end, 1)
local handle = Timer.setInterval(function() print("tick") end, 2)
-- handle.Stop()
```

### TweenUtil
- Create tweens and await them easily.
- API: `tween`, `tweenAsync`, `sequence`.

```lua
local part = workspace.Part
TweenUtil.tweenAsync(part, TweenInfo.new(1, Enum.EasingStyle.Quad), {Transparency = 1})
```

### TeleportUtil
- In-server repositioning and cross-place/server teleports with retries.
- Server-side recommended for TeleportService.

```lua
-- same-server move
TeleportUtil.teleportInServer(player, workspace.SpawnLocation, { keepOrientation = true, offset = Vector3.new(0, 2, 0) })

-- cross-place
local ok, err = TeleportUtil.teleportToPlace(1234567890, player, { from = game.PlaceId })
if not ok then warn("Teleport failed", err) end
```

### InstanceUtil
- Build/fetch/wait/destroy helpers for Instances.

```lua
local folder = InstanceUtil.getOrCreate(workspace, "Folder", "Stuff")
local part = InstanceUtil.create("Part", { Name = "P", Parent = folder, Anchored = true })
```

### TableUtil

```lua
```

### StringUtil
- Trimming, splitting, joining, casing, padding, slugify, thousands formatting.

```lua
StringUtil.trim("  hi  ") -- "hi"
StringUtil.slugify("Hello World!!") -- "hello-world"
```

### MathUtil
### RaycastUtil
- Raycast helpers for common operations.

```lua
local params = RaycastUtil.params({character}, "Exclude")
RaycastUtil.ignoreCharacter(params, player)
local hit = RaycastUtil.raycastFromTo(Vector3.new(0,10,0), Vector3.new(0,0,0), params)
```

### ColorUtil
- Color3 conversions and adjustments.

```lua
local c = ColorUtil.fromHex("#FFAA00")
local lighter = ColorUtil.lighten(c, 0.2)
print(ColorUtil.toHex(lighter))
```

### HttpUtil (server)
- RequestAsync wrapper with retries and JSON helpers.

```lua
local ok, res, err = HttpUtil.get("https://httpbin.org/get", nil, { retries = 2 })
if ok then print(res.StatusCode, res.Body) else warn(err) end
```

### DataStoreUtil (server)
- DataStore helpers with retries and request budget waits.

```lua
local store = DataStoreUtil.getStore("PlayerData")
local ok, data = DataStoreUtil.get(store, player.UserId)
local ok2, newCoins = DataStoreUtil.increment(store, player.UserId..":coins", 1)
```

### CollectionUtil
- Tag utilities using CollectionService.

```lua
CollectionUtil.addTag(part, "Enemy")
local conn = CollectionUtil.onAdded("Enemy", function(inst) print("enemy tagged:", inst) end)
```

### TimeUtil
- Duration and ISO timestamp formatting.
### SoundUtil
- Play and preload sounds with optional fades and a stop/destroy handle.

```lua
local sound, handle = Modules.SoundUtil.play("rbxassetid://123456", {
	parent = workspace,
	volume = 0.7,
	fadeIn = 0.5,
	fadeOut = 0.25,
	destroyOnEnd = true,
})
-- Later: handle.Stop() or handle.FadeOut(0.25)
```

### CameraUtil (client)
- Set camera subject, tween to CFrame, simple shake.

```lua
local CameraUtil = Modules.CameraUtil
CameraUtil.setSubject(nil) -- manual control
CameraUtil.tweenTo(CFrame.new(0,20,0), TweenInfo.new(1))
local shake = CameraUtil.shake(0.6, 0.2, 15)
-- shake.Stop()
```

### CFrameUtil
- Utility functions for CFrame math: lookAt, yaw/pitch/roll conversions, rotateAround, clampYaw.

```lua
local cf = Modules.CFrameUtil.lookAt(Vector3.new(0,5,0), Vector3.new(0,0,0))
local clamped = Modules.CFrameUtil.clampYaw(cf, -math.rad(90), math.rad(90))
```

### RandomUtil
- RNG wrapper: integers, numbers, choice, shuffle, sample, weighted, bag draws.

```lua
local RNG = Modules.RandomUtil.new(42)
local nums = RNG:sample({1,2,3,4,5}, 3, true)
local pick = RNG:weighted({ {item="A", weight=1}, {item="B", weight=3} })
```

### RateLimiter
- Token-bucket limiter per key (capacity + refill rate per second).
### NotificationUtil (client)
- Simple toast notifications on the client.

```lua
Modules.NotificationUtil.show("Welcome!", { duration = 3, stroke = true })
```

### StateMachine
- Tiny FSM with onEnter/onExit hooks and a stateChanged signal.

```lua
local fsm = Modules.StateMachine.new("Idle")
fsm:addState("Idle", { onExit = function(next) print("exit Idle ->", next) end })
fsm:addState("Run", { onEnter = function(prev) print("enter Run from", prev) end })
fsm.stateChanged:Connect(function(current, previous) print("state:", previous, "->", current) end)
fsm:transition("Run")
```

### ProgressBar (client)
- Simple progress bar component.

```lua
local bar = Modules.ProgressBar.create()
bar:SetText("Loading...")
bar:SetProgress(0)
for i = 1, 100 do
	bar:SetProgress(i/100, 0.02)
	task.wait(0.02)
end
bar:SetText("Done")
```

```lua
local limiter = Modules.RateLimiter.new(5, 2) -- capacity 5, refill 2 tokens/sec
local ok, remaining = limiter:allow("player:"..player.UserId)
if not ok then return end -- deny action
```
### PromiseUtil
- Lightweight Promises and helpers (resolve/reject, andThen/catch/finally, all, race, delay, timeout, retry).

```lua
local Promise = Modules.PromiseUtil
Promise.retry(function()
	-- work that may fail
	if math.random() < 0.5 then error("flaky") end
	return "ok"
end, 3, 0.5):andThen(function(res)
	print("res", res)
end):catch(function(err)
	warn("failed", err)
end)
```

### PlayerUtil
- Safe character/humanoid/HRP utilities.

```lua
local char = PlayerUtil.waitForCharacter(player, 5)
local hum = PlayerUtil.waitForHumanoid(player, 5)
if hum and PlayerUtil.isAlive(hum) then
	print("alive")
end
```

### LeaderstatsUtil (server)
- Create and manage leaderstats quickly; optional persistence with DataStoreUtil.

```lua
local store = DataStoreUtil.getStore("Leaderstats")
LeaderstatsUtil.bindAutoSetup(game:GetService("Players"))
LeaderstatsUtil.addInt(player, "Coins", 0)
LeaderstatsUtil.increment(player, "Coins", 5)

-- Optional persistence
local hooks = LeaderstatsUtil.attachPersistence(store, function(p) return "ls:"..p.UserId end)
hooks.load(player)
hooks.save(player)
```

```lua
TimeUtil.formatDuration(3671) -- "01:01:11"
TimeUtil.iso8601() -- e.g. "2025-11-03T12:34:56Z"
```
- Common math helpers: `clamp`, `lerp`, `remap`, rounding, approx, random, weighted choice.

```lua
MathUtil.remap(5, 0, 10, 0, 1, true) -- 0.5
```

## Folder placement
- ServerScriptService: best for server-only utilities (TeleportUtil usage).
- ReplicatedStorage: for shared modules (most utilities).

## Notes
- Written in Luau and safe for vanilla Roblox Studio.
- Minimal dependencies; each file is standalone.
