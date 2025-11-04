# Useful Functions (Roblox Luau)

Lightweight, reusable utilities for Roblox projects. Shared, Client, and Server bundles give you clean requires and clear separation.

## What is this?

This repo is a grab‑bag of production‑ready Luau utilities: signals, timers, math/geometry, UI helpers, data helpers, and server services (teleport, datastores, messaging, matchmaking, etc.).

For a complete API index (all modules and functions), see API.md.

## Setup

Recommended (Rojo):

1) Keep the repo structure and sync with the included `default.project.json`.
2) After syncing, you’ll see:
	 - `ReplicatedStorage.UsefulFunctions` (Shared bundle)
	 - `ReplicatedStorage.UsefulFunctionsClient` (Client bundle)
	 - `ServerScriptService.UsefulFunctions.UsefulFunctionsServer` (Server bundle)

Manual drop‑in (alternative):

- Place the `Modules` folder in ReplicatedStorage and keep the top‑level `UsefulFunctions*.lua` entry points as mapped in the Rojo project, or require `ReplicatedStorage.Modules.init` directly.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Shared (client or server)
local Shared = require(ReplicatedStorage.UsefulFunctions)
local Maid = Shared.Maid
local m = Maid.new(); m:GiveTask(function() print("cleanup") end); m:Cleanup()

-- Client-only
local Client = require(ReplicatedStorage.UsefulFunctionsClient)
-- Client.NotificationUtil.show("Hello!")

-- Server-only
local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)
-- local ok, err = Server.TeleportUtil.teleportToPlace(1234567890, player)
```

## API Reference

See API.md for a compact list of every module with its functions and usage notes.

## Tests

- Client tests: `Tests/AllModules.client.lua` (mapped to StarterPlayerScripts)
- Server tests: `Tests/AllModules.server.lua` (mapped to ServerScriptService/Tests)

Press Play in Studio and watch the Output for pass/fail summaries.

-- Direct setters
Mv.setWalkSpeed(player, 20)
Mv.setJumpPower(player, 60)    -- switches to JumpPower mode
Mv.setJumpHeight(player, 8)    -- switches to JumpHeight mode
Mv.setAutoRotate(player, false)
Mv.setHipHeight(player, 2)

-- Temporary boost (auto-restores after duration)
local ok, restore = Mv.tempWalkSpeed(player, 1.5, { mode = "mul", duration = 5 })
-- Optionally: restore() early

### CharacterHealthUtil (server)

Manipulate health and toggle simple invulnerability.

```lua
local HP = ServerModules.CharacterHealthUtil
HP.setMaxHealth(player, 200)
HP.heal(player, 25)
HP.damage(player, 10)

-- Make invulnerable for 3 seconds
local ok, disable = HP.setInvulnerable(player, true, { duration = 3 })
-- Or disable() early
```

### CharacterVisibilityUtil (server)

Make characters invisible/visible or non-colliding (ghost mode).

```lua
local Vis = ServerModules.CharacterVisibilityUtil
Vis.setInvisible(player, true)              -- fully invisible (Transparency=1)
Vis.setInvisible(player, false)             -- visible again
Vis.setGhostMode(player, true)              -- non-colliding but visible
Vis.setTransparency(player, 0.5, { nonCollide = true })
```

### CharacterAppearanceUtil (server)

Apply outfits and tweak colors/accessories.

```lua
local App = ServerModules.CharacterAppearanceUtil

-- Apply the player's Roblox outfit (or another user)
App.applyUserOutfit(player, player.UserId)

-- Apply outfit by outfit id
App.applyOutfitId(player, 1234567890)

-- Set classic body colors (BrickColor or Color3)
App.setBodyColors(player, {
	Head = BrickColor.new("Bright yellow"),
	Torso = Color3.fromRGB(255, 204, 153),
})

-- Add/remove accessories (when you already have an Accessory instance)
-- App.addAccessory(player, accessory)
-- App.removeAccessories(player, function(acc) return acc.Name == "Hat" end)
```

## Folder placement
- ServerScriptService: best for server-only utilities (TeleportUtil usage).
- ReplicatedStorage: for shared modules (most utilities).

## Notes
- Written in Luau and safe for vanilla Roblox Studio.
- Minimal dependencies; each file is standalone.
