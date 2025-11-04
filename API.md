# Useful Functions — API Reference

A compact, practical API index for all modules. Grouped by bundle:

- Shared (client + server): `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `local Client = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Tip: In Studio, individual modules are also mapped under ReplicatedStorage/ServerScriptService for convenience, but bundle requires are recommended.

---

## Shared modules

All available from the Shared bundle (`Modules.X`).

### Signal — lightweight events
- new(); Connect(fn); Once(fn); Fire(...); Wait(); Destroy()
- Usage: `local sig = Modules.Signal.new(); local c = sig:Connect(print); sig:Fire("hi")`

### Maid — cleanup aggregator
- new(); GiveTask(x); Cleanup(); DoCleaning(); Destroy()
- Usage: `local m = Modules.Maid.new(); m:GiveTask(conn); m:Cleanup()`

### Debounce — debounce/throttle
- debounce(fn, seconds) — only call after quiet period
- throttle(fn, seconds) — rate-limit calls

### Timer — tiny scheduler
- wait(seconds)
- setTimeout(fn, delay)
- setInterval(fn, interval) — returns handle with Stop()

### TweenUtil — tween numbers/props
- tween(instance|number, info, goalProps|onStep)
- tweenAsync(instance, info, goalProps)
- sequence(instance, steps)

### InstanceUtil — instance helpers
- create(class, props?, children?)
- getOrCreate(parent, class, name?)
- waitForDescendant(parent, name, timeout?)
- destroyChildren(parent, predicate?)
- cloneInto(source, parent, props?)

### TableUtil — table helpers
- copy(t, deep?)
- assign(target, ...)
- mergeDeep(target, ...)
- equals(a, b, deep?)
- map(list, fn); filter(list, fn); find(list, fn)
- keys(t); values(t); isArray(t)

### StringUtil — string helpers
- ltrim; rtrim; trim; split; join; startsWith; endsWith
- capitalize; toTitleCase; padLeft; padRight; slugify; formatThousands

### MathUtil — math helpers
- clamp; lerp; invLerp; remap; round; roundTo; floorTo; ceilTo; approxEqual; randomRange; chooseWeighted

### CFrameUtil — CFrame helpers
- lookAt; fromYawPitchRoll; toYawPitchRoll; rotateAround; offset; clampYaw

### VectorUtil — Vector3 helpers
- clampMagnitude; horizontal; distance; distanceXZ; project; reject; angleBetween; fromYawPitch; approximately; lerp

### RaycastUtil — raycast helpers
- params(list?, mode?) — Include/Exclude list
- ignoreCharacter(params, playerOrModel)
- raycast(origin, dir, params?)
- raycastFromTo(a, b, params?)
- ground(pos, maxDistance?, params?)

### ColorUtil — Color3 helpers
- fromHex; toHex; fromRGB; toRGB; lerp; lighten; darken

### CollectionUtil — CollectionService tags
- addTag; removeTag; hasTag; getTagged
- onAdded(tag, cb); onRemoved(tag, cb); watchTag(tag, onAdded, onRemoved?)

### TimeUtil — time formatting
- nowUnix; formatDuration; humanize; iso8601; localISO

### PatternUtil — Lua pattern utils
- escapePattern; findAll; matchAll; replace; count; splitByPattern
- startsWithPattern; endsWithPattern; wildcardToPattern

### PromiseUtil — Promises
- new(executor); isSettled(); andThen(); catch(); finally()
- resolve(); reject(); delay(); all(); race(); timeout(); retry()

### PlayerUtil — player/character
- getPlayerFromCharacter(model)
- getHumanoid(target); getHRP(target)
- waitForCharacter(player, timeout?); waitForHumanoid(target, timeout?); waitForHRP(target, timeout?)
- isAlive(target)

### SoundUtil — sound helpers
- preload(list)
- play(soundOrId, opts) -> (Sound, Handle)

### RandomUtil — RNG convenience
- new(seed?) -> RNG
- :integer(min, max); :number(min, max); :choice(list); :shuffle(list, inPlace?)
- :sample(list, k, unique?); :weighted(entries); :bag(items)

### RateLimiter — token bucket
- new(capacity, refillPerSecond)
- :allow(key, tokens?) -> (ok, remaining)
- :setCapacity(n); :setRefillPerSecond(n); :getState(key)

### StateMachine — finite state machine
- new(initial); :addState(name, def?); :can(target); :transition(target, data?); :destroy()

### CooldownUtil — per-key cooldowns
- new(defaultDuration)
- :set(key, duration?); :timeRemaining(key); :canUse(key); :use(key); :clear(key)

### CacheUtil — TTL cache
- new(defaultTtl?, maxSize?)
- :set(key, v, ttl?); :get(key); :getOrCompute(key, producer, ttl?)
- :delete(key); :clear(); :size()

### UUIDUtil — ids/strings
- guid(); randomString(len?, charset?); shortId(len?)

### Observable — reactive value
- new(initial); :get(); :set(v); :Destroy(); .Changed (Signal)

### GeometryUtil — geometry helpers
- aabbFromPoints(points); aabbToCFrameSize(minV, maxV); aabbFromInstance(inst)
- rayPlaneIntersection(rayOrigin, rayDir, planePoint, planeNormal)
- closestPointOnSegment(a, b, p); pointInTriangle2D(p, a, b, c)

### EasingUtil — easing curves
- linear; quad/cubic/quart/quint In|Out|InOut; sine In|Out|InOut
- expo/circ/back/bounce/elastic variants

### DeepTableUtil — deep ops
- deepClone; deepMerge; getIn; setIn; equalsDeep

### StatUtil — stats helpers
- ema(prev, x, alpha)
- Running() -> object with :push(x), :mean(), fields min/max/count

### HashUtil — hashes
- stringHash(s); stableHash(value)

### LRUCache — LRU map with TTL
- new(capacity)
- :set(key, v, ttl?); :get(key); :delete(key); :clear(); :len()

### Memoize — memoize wrapper
- wrap(fn, {capacity?, ttl?}) -> (memoizedFn, cache)

### EventBus — pub/sub
- new(); :subscribe(topic, fn); :publish(topic, ...); :once(topic, fn)
- :hasSubscribers(topic); :Destroy()

### Deque — double-ended queue
- new(); :pushLeft(v); :pushRight(v); :popLeft(); :popRight(); :peekLeft(); :peekRight(); :clear(); :len()

### PriorityQueue — min-heap
- new(lessFn?); :push(v); :pop(); :peek(); :len()

---

## Client modules

All available from the Client bundle (`Client.X`).

### CameraUtil — camera helpers
- setSubject(subject?)
- tweenTo(cf, info, focus?)
- shake(duration, magnitude?, frequency?)

### NotificationUtil — quick toasts
- show(text, opts)

### NotificationQueue — queued/stacked toasts
- new(opts); :destroy(); :setMaxVisible(n); :setGap(px); :setPosition(pos, anchor?)
- :clear(); :show(text, opts); :enqueue(text, opts)

### ModalUtil — confirm dialogs
- confirm(opts) -> Promise

### ClientRateLimiter — client-side limiter
- new(capacity, refillPerSecond); :allow(key, tokens?)

### ProgressBar — simple progress UI
- create(parent?, opts?) -> Bar
- Bar:SetProgress(alpha, tweenSec?); :SetText(text?); :Show(); :Hide(); :Destroy()

### InputUtil — input helpers
- bindAction(name, callback, touchEnabled?, keys?)
- bindOnce(...)
- onKey(keyCode, fn)
- isTouch(); isGamepad(); isKeyboardMouse()

### DeviceUtil — device info
- viewport(); platform(); isSmallScreen(); safeAreaInset()

### ScreenFadeUtil — fade overlay
- fadeIn(duration); fadeOut(duration); flash(duration)

### GuiDragUtil — draggable frames
- attach(frame, opts) -> stopFn

### ViewportUtil — ViewportFrame helpers
- createViewport(size, bg?) -> ViewportFrame
- setModel(vpf, model, opts)

### CursorUtil — mouse cursor
- show(); hide(); setIcon(id); lockCenter(enable); isLocked()

### ScreenShakeUtil — camera shake
- start({ amplitude, frequency, duration, decay? }) -> stopFn

### HighlightUtil — highlight parts/models
- show(target, options) -> (Highlight, cleanupFn)

### TooltipUtil — hover tooltips
- bind(guiObject, options) -> unbindFn

### HapticUtil — gamepad rumble
- rumble(gamepad, intensity, duration); rumbleAll(intensity, duration)

### ScreenResizeUtil — viewport size changes
- onResize(handler) -> RBXScriptConnection; getViewportSize()

### CursorRayUtil — screen-to-world/raycast
- screenPointToRay(point, depth?)
- mouseRay(depth?)
- raycastFromScreenPoint(point, params?)
- raycastMouse(params?)
- worldPointFromScreen(point, depth)
- worldPointFromMouse(depth)

### ButtonFXUtil — hover/press scale FX
- bind(button, options) -> unbindFn

### LayoutUtil — UI layout builders
- createList(options); createGrid(options); createTable(options); createPadding(options)

### KeybindHintUtil — keybind hints
- show(options) -> id; remove(id)

### TouchGestureUtil — pan/pinch/rotate
- bind(options?) -> controller (OnPan/OnPinch/OnRotate) ; :Destroy()

### OffscreenIndicatorUtil — edge arrows
- attach(target, options) -> stopFn

### ScrollUtil — smooth scroll
- smoothScrollTo(scroller, target, tweenInfo?); scrollBy(scroller, dx, dy, tweenInfo?)

### SliderUtil — horizontal slider
- create(options) -> slider with OnChanged and :SetValue(v)

---

## Server modules

All available from the Server bundle (`Server.X`).

### TeleportUtil — teleports
- teleportInServer(target, destination, options?)
- teleportToPlace(placeId, players, teleportData?, options?)
- teleportToPlaceInstance(placeId, jobId, players, teleportData?, options?)
- reserveServer(placeId)
- teleportToPrivateServer(placeId, players, teleportData?, options?)

### MatchmakingUtil — queue/party matching
- new(placeId, partySize, opts)
- :onMatched(cb); :enqueue(player); :dequeue(player); :size(); :flush(); :destroy()

### HttpUtil — HTTP requests
- request(opts); get(url, headers?, opts?); post(url, body, headers?, opts?); fetchJson(url, opts?)
- encode(value); decode(str)

### DataStoreUtil — DataStore helpers
- getStore(name, scope?)
- waitForBudget(type, min?, timeout?)
- get(store, key, opts?); set(store, key, value, opts?)
- update(store, key, fn, opts?); increment(store, key, delta, opts?)
- remove(store, key, opts?)

### LeaderstatsUtil — leaderstats
- addNumber/addInt/addString(player, name, initial?)
- get(player, name); getNumber(player, name)
- set(player, name, value); increment(player, name, delta)
- bindAutoSetup(Players); attachPersistence(store, keyFn)

### MessagingServiceUtil — pub/sub
- publish(topic, data, opts?)
- subscribe(topic, handler, opts?)

### MemoryStoreUtil — queues/maps
- queue(name) -> { enqueue(payload, ttl), tryDequeue(count, timeout) }
- map(name) -> { get(key), set(key, value, ttl), increment(key, delta, ttl), remove(key) }

### BadgeUtil — badges
- hasBadge(userIdOrPlayer, badgeId)
- awardIfNotOwned(userIdOrPlayer, badgeId)

### GroupUtil — group info
- getRoleInGroup(userIdOrPlayer, groupId)
- getRankInGroup(userIdOrPlayer, groupId)
- isInGroup(userIdOrPlayer, groupId, minRank)

### MarketplaceUtil — purchases
- ownsGamePass(player, gamePassId); promptGamePass(player, gamePassId); promptProduct(player, productId)
- createReceiptRouter(map); bindProcessReceipt(fn)

### PolicyUtil — policy checks
- getPolicy(player)
- arePaidRandomItemsRestricted(player)
- isSubjectToChinaPolicies(player)
- isVoiceEnabled(player)

### BanUtil — bans
- ban(userIdOrPlayer, reason, durationSeconds, by?)
- unban(userIdOrPlayer)
- getBan(userIdOrPlayer); isBanned(userIdOrPlayer)
- shouldKick(player)

### WebhookUtil — JSON webhooks
- postJson(url, payload, opts)

### ChatFilterUtil — text filter
- filterForBroadcast(text, fromUserId)
- filterForUser(text, fromUserId, toUserId)

### AccessControlUtil — feature gates
- canUseFeature(player, rules, deps?)

### JobScheduler — background jobs
- new(name, opts)
- :enqueue(payload, ttl?)
- :startWorker(handler); :stopWorker()

### AuditLogUtil — batched logging
- new(url, opts)
- :setDestination(url); :log(eventName, fields)
- :start(); :stop()

### CharacterScaleUtil — R15 scaling
- getScales(target) -> { height,width,depth,head }
- setScale(target, {height,width,depth,head}, options?)
- setUniformScale(target, scale, options?)
- tweenScale(target, scales, tweenInfo, options?)
- tweenUniformScale(target, scale, tweenInfo, options?)
- reset(target)

### CharacterMovementUtil — movement properties
- get(target) -> table { WalkSpeed, JumpPower/JumpHeight, AutoRotate, HipHeight, MaxSlopeAngle }
- set(target, props)
- setWalkSpeed(target, speed)
- setJumpPower(target, power) — switches to JumpPower mode
- setJumpHeight(target, height) — switches to JumpHeight mode
- setAutoRotate(target, enabled); setHipHeight(target, height)
- tempWalkSpeed(target, value, { mode = "set"|"add"|"mul", duration? }) -> (true, restoreFn)
- apply(target, props) -> (true, restoreFn)

### CharacterAppearanceUtil — outfits/colors/accessories
- applyDescription(target, HumanoidDescription)
- applyUserOutfit(target, userId)
- applyOutfitId(target, outfitId)
- setBodyColors(targetOrCharacter, colors)
- addAccessory(target, accessory)
- removeAccessories(target, predicate?)
- setClothingIds(target, shirtId?, pantsId?)

### CharacterVisibilityUtil — transparency/ghost
- setTransparency(target, alpha, options?) — options.nonCollide?
- setInvisible(target, enabled, options?)
- setGhostMode(target, enabled)

### CharacterHealthUtil — health/invulnerability
- setMaxHealth(target, maxHealth, options?)
- heal(target, amount)
- damage(target, amount)
- setInvulnerable(target, enabled, options?) -> (true, disableFn?)

---

## Usage notes
- Prefer bundle requires; they export all modules as fields.
- Server-only modules must be required on the server.
- For practical examples, see `Tests/AllModules.client.lua` and `Tests/AllModules.server.lua`.
