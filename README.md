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

### CameraUtil (client)

```lua
Modules.CameraUtil.setSubject(nil)
Modules.CameraUtil.tweenTo(CFrame.new(0,20,0), TweenInfo.new(1))
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

## Folder placement
- ServerScriptService: best for server-only utilities (TeleportUtil usage).
- ReplicatedStorage: for shared modules (most utilities).

## Notes
- Written in Luau and safe for vanilla Roblox Studio.
- Minimal dependencies; each file is standalone.
