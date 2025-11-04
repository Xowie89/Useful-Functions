# Useful Functions (Roblox Luau) — Compact API Index

Lightweight, reusable utilities split into Shared, Client, and Server bundles.

## Require (bundles)

- Shared (client + server): `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `local Client = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Rojo: `default.project.json` maps Shared/Client modules to ReplicatedStorage and Server modules to ServerScriptService.

## Quick start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = require(ReplicatedStorage.UsefulFunctions)

local maid = Modules.Maid.new()
maid:GiveTask(function() print("cleanup") end)
maid:Cleanup()
```

## Shared modules (require from Shared bundle)

- Signal — events
	- new(); Connect(fn); Once(fn); Fire(...); Wait(); Destroy()
- Maid — cleanup aggregator
	- new(); GiveTask(x); Cleanup(); DoCleaning(); Destroy()
- Debounce — debounce/throttle
	- debounce(fn, seconds); throttle(fn, seconds)
- Timer — tiny scheduler
	- wait(seconds); setTimeout(fn, delay); setInterval(fn, interval)
- TweenUtil — tween numbers/props
	- tween(instance|number, info, goal?|onStep); tweenAsync(...); sequence(instance, steps)
- InstanceUtil — instance helpers
	- create(class, props?, children?); getOrCreate(parent, class, name?); waitForDescendant(parent, name, timeout?);
	- destroyChildren(parent, predicate?); cloneInto(source, parent, props?)
- TableUtil — table basics
	- copy(t, deep?); assign(target, ...); mergeDeep(target, ...); equals(a, b, deep?);
	- map(list, fn); filter(list, fn); find(list, fn); keys(t); values(t); isArray(t)
- StringUtil — string helpers
	- ltrim; rtrim; trim; split; join; startsWith; endsWith; capitalize; toTitleCase; padLeft; padRight; slugify; formatThousands
- MathUtil — math helpers
	- clamp; lerp; invLerp; remap; round; roundTo; floorTo; ceilTo; approxEqual; randomRange; chooseWeighted
- CFrameUtil — CFrame helpers
	- lookAt; fromYawPitchRoll; toYawPitchRoll; rotateAround; offset; clampYaw
- VectorUtil — Vector3 helpers
	- clampMagnitude; horizontal; distance; distanceXZ; project; reject; angleBetween; fromYawPitch; approximately; lerp
- RaycastUtil — raycast helpers
	- params(list?, mode?); ignoreCharacter(params, playerOrModel); raycast(origin, dir, params?); raycastFromTo(a, b, params?); ground(pos, dist?, params?)
- ColorUtil — Color3 helpers
	- fromHex; toHex; fromRGB; toRGB; lerp; lighten; darken
- CollectionUtil — CollectionService tags
	- addTag; removeTag; hasTag; getTagged; onAdded(tag, cb); onRemoved(tag, cb); watchTag(tag, onAdded, onRemoved?)
- TimeUtil — time formatting
	- nowUnix; formatDuration; humanize; iso8601; localISO
- PatternUtil — Lua pattern utilities
	- escapePattern; findAll; matchAll; replace; count; splitByPattern; startsWithPattern; endsWithPattern; wildcardToPattern
- PromiseUtil — Promises
	- new(executor); isSettled(); andThen(); catch(); finally(); resolve(); reject(); delay(); all(); race(); timeout(); retry()
- PlayerUtil — player/character
	- getPlayerFromCharacter(model); getHumanoid(target); getHRP(target); waitForCharacter(player, timeout?);
	- waitForHumanoid(target, timeout?); waitForHRP(target, timeout?); isAlive(target)
- SoundUtil — sound helpers
	- preload(list); play(soundOrId, opts) -> (Sound, Handle)
- RandomUtil — RNG convenience
	- new(seed?); :integer(min, max); :number(min, max); :choice(list); :shuffle(list, inPlace?); :sample(list, k, unique?); :weighted(entries); :bag(items)
- RateLimiter — token bucket
	- new(capacity, refillPerSecond); :allow(key, tokens?)->(ok, remaining); :setCapacity(n); :setRefillPerSecond(n); :getState(key)
- StateMachine — finite state machine
	- new(initial); :addState(name, def?); :can(target); :transition(target, data?); :destroy()
- CooldownUtil — per-key cooldowns
	- new(defaultDuration); :set(key, duration?); :timeRemaining(key); :canUse(key); :use(key); :clear(key)
- CacheUtil — TTL cache
	- new(defaultTtl?, maxSize?); :set(key, v, ttl?); :get(key); :getOrCompute(key, producer, ttl?); :delete(key); :clear(); :size()
- UUIDUtil — ids/strings
	- guid(); randomString(len?, charset?); shortId(len?)
- Observable — reactive value
	- new(initial); :get(); :set(v); :Destroy(); .Changed (Signal)
- GeometryUtil — geometry helpers
	- aabbFromPoints(points); aabbToCFrameSize(minV, maxV); aabbFromInstance(inst); rayPlaneIntersection(...);
	- closestPointOnSegment(a, b, p); pointInTriangle2D(p, a, b, c)
- EasingUtil — easing curves
	- linear; quad/cubic/quart/quint In|Out|InOut; sine In|Out|InOut; expo/circ/back/bounce/elastic variants
- DeepTableUtil — deep ops
	- deepClone; deepMerge; getIn; setIn; equalsDeep
- StatUtil — stats helpers
	- ema(prev, x, alpha); Running() -> object with :push(x), :mean(), fields min/max/count
- HashUtil — hashes
	- stringHash(s); stableHash(value)
- LRUCache — LRU map with TTL
	- new(capacity); :set(key, v, ttl?); :get(key); :delete(key); :clear(); :len()
- Memoize — memoize wrapper
	- wrap(fn, {capacity?, ttl?}) -> (memoizedFn, cache)
- EventBus — pub/sub
	- new(); :subscribe(topic, fn); :publish(topic, ...); :once(topic, fn); :hasSubscribers(topic); :Destroy()
- Deque — double-ended queue
	- new(); :pushLeft(v); :pushRight(v); :popLeft(); :popRight(); :peekLeft(); :peekRight(); :clear(); :len()
- PriorityQueue — min-heap
	- new(lessFn?); :push(v); :pop(); :peek(); :len()

## Client modules (require from Client bundle)

- CameraUtil — camera helpers
	- setSubject(subject?); tweenTo(cf, info, focus?); shake(duration, magnitude?, frequency?)
- NotificationUtil — quick toast
	- show(text, opts)
- NotificationQueue — queued toasts
	- new(opts); :destroy(); :setMaxVisible(n); :setGap(px); :setPosition(pos, anchor?); :clear(); :show(text, opts); :enqueue(text, opts)
- ModalUtil — confirm dialogs
	- confirm(opts) -> Promise
- ClientRateLimiter — advisory limiter
	- new(capacity, refillPerSecond); :allow(key, tokens?)
- ProgressBar — simple progress UI
	- create(parent?, opts?) -> Bar; Bar:SetProgress(alpha, tweenSec?); :SetText(text?); :Show(); :Hide(); :Destroy()
- InputUtil — input helpers
	- bindAction(name, callback, touchEnabled?, keys?); bindOnce(...); onKey(keyCode, fn);
	- isTouch(); isGamepad(); isKeyboardMouse()
- DeviceUtil — device info
	- viewport(); platform(); isSmallScreen(); safeAreaInset()
- ScreenFadeUtil — fade overlay
	- fadeIn(duration); fadeOut(duration); flash(duration)
- GuiDragUtil — drag frames
	- attach(frame, opts) -> stopFn
- ViewportUtil — ViewportFrame helpers
	- createViewport(size, bg?) -> frame; setModel(vpf, model, opts)
- CursorUtil — mouse cursor
	- show(); hide(); setIcon(id); lockCenter(enable); isLocked()
- ScreenShakeUtil — camera shake
	- start({amplitude, frequency, duration, decay?}) -> stopFn
- HighlightUtil — highlight parts/models
	- show(target, opts) -> (Highlight, cleanupFn)
- TooltipUtil — hover tooltips
	- bind(guiObject, opts) -> unbindFn
- HapticUtil — gamepad rumble
	- rumble(gamepad, intensity, duration); rumbleAll(intensity, duration)
- ScreenResizeUtil — viewport changes
	- onResize(handler) -> RBXScriptConnection; getViewportSize()
- CursorRayUtil — screen-to-world
	- screenPointToRay(pt, depth?); mouseRay(depth?); raycastFromScreenPoint(pt, params?); raycastMouse(params?);
	- worldPointFromScreen(pt, depth); worldPointFromMouse(depth)
- ButtonFXUtil — button scaling FX
	- bind(button, options) -> unbindFn
- LayoutUtil — UI layout builders
	- createList(opts); createGrid(opts); createTable(opts); createPadding(opts)
- KeybindHintUtil — on-screen hints
	- show(opts) -> id; remove(id)
- TouchGestureUtil — pan/pinch/rotate
	- bind(opts?) -> controller with events OnPan/OnPinch/OnRotate; :Destroy()
- OffscreenIndicatorUtil — edge arrows
	- attach(target, opts) -> stopFn
- ScrollUtil — smooth scroll
	- smoothScrollTo(scroller, target, tweenInfo?); scrollBy(scroller, dx, dy, tweenInfo?)
- SliderUtil — horizontal slider
	- create(opts) -> slider with OnChanged, :SetValue(v)

## Server modules (require from Server bundle)

- TeleportUtil — teleports
	- teleportInServer(target, destination, opts?); teleportToPlace(placeId, players, data?, opts?);
	- teleportToPlaceInstance(placeId, jobId, players, data?, opts?); reserveServer(placeId);
	- teleportToPrivateServer(placeId, players, data?, opts?)
- MatchmakingUtil — queue/party matching
	- new(placeId, partySize, opts); :onMatched(cb); :enqueue(player); :dequeue(player); :size(); :flush(); :destroy()
- HttpUtil — HTTP
	- request(opts); get(url, headers?, opts?); post(url, body, headers?, opts?); fetchJson(url, opts?); encode(v); decode(str)
- DataStoreUtil — DataStore helpers
	- getStore(name, scope?); waitForBudget(type, min?, timeout?); get(store, key, opts?); set(store, key, value, opts?);
	- update(store, key, fn, opts?); increment(store, key, delta, opts?); remove(store, key, opts?)
- LeaderstatsUtil — leaderstats
	- addNumber/addInt/addString(player, name, initial?); get(player, name); getNumber(player, name);
	- set(player, name, v); increment(player, name, delta); bindAutoSetup(Players); attachPersistence(store, keyFn)
- MessagingServiceUtil — pub/sub
	- publish(topic, data, opts?); subscribe(topic, handler, opts?)
- MemoryStoreUtil — queues/maps
	- queue(name) -> { enqueue, tryDequeue }; map(name) -> { get, set, increment, remove }
- BadgeUtil — badges
	- hasBadge(userIdOrPlayer, badgeId); awardIfNotOwned(userIdOrPlayer, badgeId)
- GroupUtil — group info
	- getRoleInGroup(userIdOrPlayer, groupId); getRankInGroup(...); isInGroup(userIdOrPlayer, groupId, minRank)
- MarketplaceUtil — purchases
	- ownsGamePass(player, gamePassId); promptGamePass(player, gamePassId); promptProduct(player, productId);
	- createReceiptRouter(map); bindProcessReceipt(fn)
- PolicyUtil — policy checks
	- getPolicy(player); arePaidRandomItemsRestricted(player); isSubjectToChinaPolicies(player); isVoiceEnabled(player)
- BanUtil — bans
	- ban(userIdOrPlayer, reason, durationSeconds, by?); unban(userIdOrPlayer); getBan(userIdOrPlayer);
	- isBanned(userIdOrPlayer); shouldKick(player)
- WebhookUtil — webhooks
	- postJson(url, payload, opts)
- ChatFilterUtil — text filter
	- filterForBroadcast(text, fromUserId); filterForUser(text, fromUserId, toUserId)
- AccessControlUtil — feature gates
	- canUseFeature(player, rules, deps?)
- JobScheduler — background jobs
	- new(name, opts); :enqueue(payload, ttl?); :startWorker(handler); :stopWorker()
- AuditLogUtil — batched logging
	- new(url, opts); :setDestination(url); :log(event, fields); :start(); :stop()
- CharacterScaleUtil — R15 scaling
	- getScales(target); setScale(target, {height,width,depth,head}, opts?); setUniformScale(target, s, opts?);
	- tweenScale(target, scales, tweenInfo, opts?); tweenUniformScale(target, s, tweenInfo, opts?); reset(target)
- CharacterMovementUtil — movement props
	- get(target); set(target, props); setWalkSpeed(target, speed); setJumpPower(target, power); setJumpHeight(target, h);
	- setAutoRotate(target, enabled); setHipHeight(target, h); tempWalkSpeed(target, value, opts) -> (ok, restore);
	- apply(target, props) -> (ok, restore)
- CharacterAppearanceUtil — outfits/colors/accessories
	- applyDescription(target, HumanoidDescription); applyUserOutfit(target, userId); applyOutfitId(target, outfitId);
	- setBodyColors(targetOrCharacter, colors); addAccessory(target, accessory); removeAccessories(target, predicate?);
	- setClothingIds(target, shirtId?, pantsId?)
- CharacterVisibilityUtil — transparency/ghost
	- setTransparency(target, alpha, opts?); setInvisible(target, enabled, opts?); setGhostMode(target, enabled)
- CharacterHealthUtil — health/invulnerability
	- setMaxHealth(target, max, opts?); heal(target, amount); damage(target, amount);
	- setInvulnerable(target, enabled, opts?) -> (true, disableFn?)

## Usage tips

- Prefer bundles for requires; individual modules are also mapped under ReplicatedStorage for convenience.
- All modules are Luau and self-contained; server-only modules must be required on the server.
- See `Tests/AllModules.client.lua` and `Tests/AllModules.server.lua` for smoke usage.

-- Direct setters
Mv.setWalkSpeed(player, 20)
Mv.setJumpPower(player, 60)    -- switches to JumpPower mode
Mv.setJumpHeight(player, 8)    -- switches to JumpHeight mode
Mv.setAutoRotate(player, false)
Mv.setHipHeight(player, 2)

-- Temporary boost (auto-restores after duration)
local ok, restore = Mv.tempWalkSpeed(player, 1.5, { mode = "mul", duration = 5 })
-- Optionally: restore() early
```

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
