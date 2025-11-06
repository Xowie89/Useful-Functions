# Useful Functions — API Reference

A compact, practical API index for all modules. Grouped by bundle:

- Shared (client + server): `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `local Client = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Tip: In Studio, individual modules are also mapped under ReplicatedStorage/ServerScriptService for convenience, but bundle requires are recommended.

## Table of contents

- [Shared modules](#shared-modules)
	- [CacheUtil](#cacheutil--ttl-cache)
	- [CFrameUtil](#cframeutil--cframe-helpers)
	- [CollectionUtil](#collectionutil--collectionservice-tags)
	- [ColorUtil](#colorutil--color3-helpers)
	- [CooldownUtil](#cooldownutil--per-key-cooldowns)
	- [Debounce](#debounce--debouncethrottle)
	- [DeepTableUtil](#deeptableutil--deep-ops)
	- [Deque](#deque--double-ended-queue)
	- [EasingUtil](#easingutil--easing-curves)
	- [EventBus](#eventbus--pubsub)
	- [FormatUtil](#formatutil--formatting-helpers)
	- [GeometryUtil](#geometryutil--geometry-helpers)
	- [HashUtil](#hashutil--hashes)
	- [InstanceUtil](#instanceutil--instance-helpers)
	- [LRUCache](#lrucache--lru-map-with-ttl)
	- [Maid](#maid--cleanup-aggregator)
	- [MathUtil](#mathutil--math-helpers)
	- [Memoize](#memoize--memoize-wrapper)
	- [Observable](#observable--reactive-value)
	- [PatternUtil](#patternutil--lua-pattern-utils)
	- [PlayerUtil](#playerutil--playercharacter)
	- [PriorityQueue](#priorityqueue--min-heap)
	- [PromiseUtil](#promiseutil--promises)
	- [RandomUtil](#randomutil--rng-convenience)
	- [RateLimiter](#ratelimiter--token-bucket)
	- [RaycastUtil](#raycastutil--raycast-helpers)
	- [Signal](#signal--lightweight-events)
	- [SoundUtil](#soundutil--sound-helpers)
	- [StateMachine](#statemachine--finite-state-machine)
	- [StatUtil](#statutil--stats-helpers)
	- [StringUtil](#stringutil--string-helpers)
	- [TableUtil](#tableutil--table-helpers)
	- [TimeUtil](#timeutil--time-formatting)
	- [Timer](#timer--tiny-scheduler)
	- [TweenUtil](#tweenutil--tween-numbersprops)
	- [UUIDUtil](#uuidutil--idsstrings)
	- [VectorUtil](#vectorutil--vector3-helpers)
- [Client modules](#client-modules)
	- [ButtonFXUtil](#buttonfxutil--hoverpress-scale-fx)
	- [CameraUtil](#camerautil--camera-helpers)
	- [ClientRateLimiter](#clientratelimiter--client-side-limiter)
	- [CursorRayUtil](#cursorrayutil--screen-to-worldraycast)
	- [CursorUtil](#cursorutil--mouse-cursor)
	- [DeviceUtil](#deviceutil--device-info)
	- [GuiDragUtil](#guidragutil--draggable-frames)
	- [HapticUtil](#hapticutil--gamepad-rumble)
	- [HighlightUtil](#highlightutil--highlight-partsmodels)
	- [InputUtil](#inpututil--input-helpers)
	- [KeybindHintUtil](#keybindhintutil--keybind-hints)
	- [LayoutUtil](#layoututil--ui-layout-builders)
	- [ModalUtil](#modalutil--confirm-dialogs)
	- [NotificationQueue](#notificationqueue--queuedstacked-toasts)
	- [NotificationUtil](#notificationutil--quick-toasts)
	- [OffscreenIndicatorUtil](#offscreenindicatorutil--edge-arrows)
	- [ProgressBar](#progressbar--simple-progress-ui)
	- [ScreenFadeUtil](#screenfadeutil--fade-overlay)
	- [ScreenResizeUtil](#screenresizeutil--viewport-size-changes)
	- [ScreenShakeUtil](#screenshakeutil--camera-shake)
	- [ScrollUtil](#scrollutil--smooth-scroll)
	- [SliderUtil](#sliderutil--horizontal-slider)
	- [TooltipUtil](#tooltiputil--hover-tooltips)
	- [TouchGestureUtil](#touchgestureutil--panpinchrotate)
	- [ViewportUtil](#viewportutil--viewportframe-helpers)
- [Server modules](#server-modules)
	- [AccessControlUtil](#accesscontrolutil--feature-gates)
	- [AllowlistUtil](#allowlistutil--join-access)
	- [AuditLogUtil](#auditlogutil--batched-logging)
	- [BadgeUtil](#badgeutil--badges)
	- [BanUtil](#banutil--bans)
	- [CharacterAppearanceUtil](#characterappearanceutil--outfitscolorsaccessories)
	- [CharacterHealthUtil](#characterhealthutil--healthinvulnerability)
	- [CharacterMovementUtil](#charactermovementutil--movement-properties)
	- [CharacterScaleUtil](#characterscaleutil--r15-scaling)
	- [CharacterVisibilityUtil](#charactervisibilityutil--transparencyghost)
	- [ChatFilterUtil](#chatfilterutil--text-filter)
	- [CrossServerEvent](#crossserverevent--cross-server-events)
	- [DataStoreUtil](#datastoreutil--datastore-helpers)
	- [DistributedLockUtil](#distributedlockutil--distributed-locks)
	- [GlobalRateLimiter](#globalratelimiter--distributed-token-bucket)
	- [GroupUtil](#grouputil--group-info)
	- [HttpUtil](#httputil--http-requests)
	- [JobScheduler](#jobscheduler--background-jobs)
	- [LeaderstatsUtil](#leaderstatsutil--leaderstats)
	- [LockdownUtil](#lockdownutil--server-lockdown)
	- [MarketplaceUtil](#marketplaceutil--purchases)
	- [MatchmakingUtil](#matchmakingutil--queueparty-matching)
	- [MaintenanceAnnouncer](#maintenanceannouncer--scheduled-maintenance)
	- [MemoryStoreUtil](#memorystoreutil--queuesmaps)
	- [MessagingServiceUtil](#messagingserviceutil--pubsub)
	- [PlayerBanEnforcer](#playerbanenforcer--auto-kick-banned)
	- [PlayerProfileUtil](#playerprofileutil--player-profiles)
	- [PlayerSessionUtil](#playersessionutil--player-sessions)
	- [PolicyUtil](#policyutil--policy-checks)
	- [ServerHeartbeat](#serverheartbeat--liveness-heartbeat)
	- [ServerMetricsUtil](#servermetricsutil--server-metrics)
	- [ServerRegistry](#serverregistry--list-active-servers)
	- [ShutdownUtil](#shutdownutil--graceful-shutdown)
	- [TeleportUtil](#teleportutil--teleports)
	- [WebhookUtil](#webhookutil--json-webhooks)
- [Usage notes](#usage-notes)

---

<a id="shared-modules"></a>
## Shared modules

All available from the Shared bundle (`Modules.X`).

<details open>
<summary>Quick index</summary>

[CacheUtil](#cacheutil--ttl-cache) · [CFrameUtil](#cframeutil--cframe-helpers) · [CollectionUtil](#collectionutil--collectionservice-tags) · [ColorUtil](#colorutil--color3-helpers) · [CooldownUtil](#cooldownutil--per-key-cooldowns) · [Debounce](#debounce--debouncethrottle) · [DeepTableUtil](#deeptableutil--deep-ops) · [Deque](#deque--double-ended-queue) · [EasingUtil](#easingutil--easing-curves) · [EventBus](#eventbus--pubsub) · [FormatUtil](#formatutil--formatting-helpers) · [GeometryUtil](#geometryutil--geometry-helpers) · [HashUtil](#hashutil--hashes) · [InstanceUtil](#instanceutil--instance-helpers) · [LRUCache](#lrucache--lru-map-with-ttl) · [Maid](#maid--cleanup-aggregator) · [MathUtil](#mathutil--math-helpers) · [Memoize](#memoize--memoize-wrapper) · [Observable](#observable--reactive-value) · [PatternUtil](#patternutil--lua-pattern-utils) · [PlayerUtil](#playerutil--playercharacter) · [PriorityQueue](#priorityqueue--min-heap) · [PromiseUtil](#promiseutil--promises) · [RandomUtil](#randomutil--rng-convenience) · [RateLimiter](#ratelimiter--token-bucket) · [RaycastUtil](#raycastutil--raycast-helpers) · [Signal](#signal--lightweight-events) · [SoundUtil](#soundutil--sound-helpers) · [StateMachine](#statemachine--finite-state-machine) · [StatUtil](#statutil--stats-helpers) · [StringUtil](#stringutil--string-helpers) · [TableUtil](#tableutil--table-helpers) · [TimeUtil](#timeutil--time-formatting) · [Timer](#timer--tiny-scheduler) · [TweenUtil](#tweenutil--tween-numbersprops) · [UUIDUtil](#uuidutil--idsstrings) · [VectorUtil](#vectorutil--vector3-helpers)

</details>

<a id="cacheutil--ttl-cache"></a>
### CacheUtil — TTL cache
- new(defaultTtlSeconds?: number, maxSize?: number) -> Cache
- Cache:set(key: string, value: any, ttlSeconds?: number)
- Cache:get(key: string) -> any
- Cache:getOrCompute(key: string, producer: () -> any, ttlSeconds?: number) -> any
- Cache:delete(key: string); Cache:clear(); Cache:size() -> number
- Example: `Modules.CacheUtil.new(60):getOrCompute("k",function() return 1 end)`

<a id="cframeutil--cframe-helpers"></a>
### CFrameUtil — CFrame helpers
- lookAt(origin: Vector3, target: Vector3, up?: Vector3) -> CFrame
- fromYawPitchRoll(y, p, r) -> CFrame; toYawPitchRoll(cf: CFrame) -> (number, number, number)
- rotateAround(cf: CFrame, origin: Vector3, axisUnit: Vector3, radians: number) -> CFrame
- offset(cf: CFrame, delta: Vector3) -> CFrame; clampYaw(cf: CFrame, minYaw: number, maxYaw: number) -> CFrame
- Example: `Modules.CFrameUtil.lookAt(Vector3.new(), Vector3.new(0,1,0))`

<a id="collectionutil--collectionservice-tags"></a>
### CollectionUtil — CollectionService tags
- addTag(inst: Instance, tag: string)
- removeTag(inst: Instance, tag: string)
- hasTag(inst: Instance, tag: string) -> boolean
- getTagged(tag: string) -> {Instance}
- onAdded(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- onRemoved(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- watchTag(tag: string, onAdded: (Instance)->(), onRemoved?: (Instance)->()) -> () -> ()
- Example: `Modules.CollectionUtil.addTag(workspace.Part,"Interactable")`

<a id="colorutil--color3-helpers"></a>
### ColorUtil — Color3 helpers
- fromHex(hex: string) -> Color3; toHex(c: Color3) -> string
- fromRGB(r,g,b) -> Color3; toRGB(c: Color3) -> (number, number, number)
- lerp(a: Color3, b: Color3, t: number) -> Color3; lighten(c: Color3, factor: number) -> Color3; darken(c: Color3, factor: number) -> Color3
- Example: `Modules.ColorUtil.fromHex("#ffaa00")`

<a id="cooldownutil--per-key-cooldowns"></a>
### CooldownUtil — per-key cooldowns
- new(defaultDuration: number) -> CD
- CD:set(key: string, duration?: number)
- CD:timeRemaining(key: string) -> number
- CD:canUse(key: string) -> boolean; CD:use(key: string) -> boolean; CD:clear(key: string)
- Example: `Modules.CooldownUtil.new(1):use("dash")`

<a id="debounce--debouncethrottle"></a>
### Debounce — debounce/throttle
- debounce(fn: (...any) -> (), waitSeconds: number) -> (...any) -> ()
- throttle(fn: (...any) -> (), intervalSeconds: number) -> (...any) -> ()
- Example: `local f=Modules.Debounce.debounce(print,0.3); f("x")`

<a id="deeptableutil--deep-ops"></a>
### DeepTableUtil — deep ops
- deepClone(t) -> any; deepMerge(dest, src) -> any
- getIn(t, path: {any}, default: any?) -> any; setIn(t, path: {any}, value: any) -> any
- equalsDeep(a, b) -> boolean
- Example: `Modules.DeepTableUtil.deepMerge({a=1},{b=2})`

<a id="deque--double-ended-queue"></a>
### Deque — double-ended queue
- new() -> Deque
- Deque:pushLeft(v); Deque:pushRight(v); Deque:popLeft() -> any; Deque:popRight() -> any
- Deque:peekLeft() -> any; Deque:peekRight() -> any; Deque:clear(); Deque:len() -> number
- Example: `Modules.Deque.new():pushRight(1)`

<a id="easingutil--easing-curves"></a>
### EasingUtil — easing curves
- linear(t)
- quad/cubic/quart/quint In|Out|InOut(t)
- sine In|Out|InOut(t); expo/circ/back/bounce/elastic variants
- Example: `Modules.EasingUtil.quadOut(0.5)`

<a id="eventbus--pubsub"></a>
### EventBus — pub/sub
- new() -> Bus
- Bus:subscribe(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:publish(topic: string, ...: any)
- Bus:once(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:hasSubscribers(topic: string) -> boolean
- Bus:Destroy()
- Example: `local b=Modules.EventBus.new(); b:publish("topic",1)`

<a id="formatutil--formatting-helpers"></a>
### FormatUtil — formatting helpers
- withCommas(n: number) -> string
- abbreviate(n: number, decimals?: number) -> string
- percent(n: number, decimals?: number) -> string
- bytes(n: number, decimals?: number) -> string
- timeAgo(seconds: number) -> string
- Example: `Modules.FormatUtil.withCommas(1234567)`

<a id="geometryutil--geometry-helpers"></a>
### GeometryUtil — geometry helpers
- aabbFromPoints(points: {Vector3}) -> (Vector3 min, Vector3 max)
- aabbToCFrameSize(minV: Vector3, maxV: Vector3) -> (CFrame, Vector3 size)
- aabbFromInstance(inst: Instance) -> (Vector3 min, Vector3 max)
- rayPlaneIntersection(rayOrigin: Vector3, rayDir: Vector3, planePoint: Vector3, planeNormal: Vector3) -> Vector3?
- closestPointOnSegment(a: Vector3, b: Vector3, p: Vector3) -> Vector3
- pointInTriangle2D(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> boolean
- Example: `Modules.GeometryUtil.aabbFromPoints({Vector3.new(),Vector3.new(1,2,3)})`

<a id="hashutil--hashes"></a>
### HashUtil — hashes
- stringHash(s: string) -> number; stableHash(value: any) -> number
- Example: `Modules.HashUtil.stringHash("abc")`

<a id="instanceutil--instance-helpers"></a>
### InstanceUtil — instance helpers
- create(className: string, props?: table, children?: {Instance}) -> Instance
- getOrCreate(parent: Instance, className: string, name?: string) -> Instance
- waitForDescendant(parent: Instance, name: string, timeoutSeconds?: number) -> Instance?
- destroyChildren(parent: Instance, predicate?: (Instance) -> boolean)
- cloneInto(source: Instance, parent: Instance, props?: table) -> Instance
- Example: `local p=Modules.InstanceUtil.create("Part",{Anchored=true})`

<a id="lrucache--lru-map-with-ttl"></a>
### LRUCache — LRU map with TTL
- new(capacity: number) -> LRU
- LRU:set(key: any, value: any, ttlSeconds?: number)
- LRU:get(key: any) -> any
- LRU:delete(key: any); LRU:clear(); LRU:len() -> number
- Example: `Modules.LRUCache.new(100):set("k","v")`

<a id="maid--cleanup-aggregator"></a>
### Maid — cleanup aggregator
- new() -> Maid
- Maid:GiveTask(task: Instance|RBXScriptConnection|() -> ())
- Maid:Cleanup()
- Maid:DoCleaning() -- alias
- Maid:Destroy()
- Example: `local m=Modules.Maid.new(); m:GiveTask(conn); m:Cleanup()`

<a id="mathutil--math-helpers"></a>
### MathUtil — math helpers
- clamp(n, minV, maxV) -> number; lerp(a, b, t) -> number; invLerp(a, b, v) -> number
- remap(v, inMin, inMax, outMin, outMax, doClamp?) -> number
- round(n, decimals?) -> number; roundTo(n, increment) -> number; floorTo(n, increment) -> number; ceilTo(n, increment) -> number
- approxEqual(a, b, eps?) -> boolean; randomRange(min, max, integer?) -> number
- chooseWeighted(entries: { {item:any, weight:number} }) -> any
- Example: `Modules.MathUtil.remap(5,0,10,0,1)`

<a id="memoize--memoize-wrapper"></a>
### Memoize — memoize wrapper
- wrap(fn: (...any)->any, options: { capacity?: number, ttl?: number }) -> (memoizedFn: (...any)->any, cache: LRUCache)
- Example: `local f=select(1,Modules.Memoize.wrap(function(x) return x*x end)); f(2)`

<a id="observable--reactive-value"></a>
### Observable — reactive value
- new(initial: any) -> Observable
- Observable:get() -> any; Observable:set(v: any)
- Observable.Changed (Signal); Observable:Destroy()
- Example: `local o=Modules.Observable.new(0); o:set(1)`

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
- Example: `Modules.PatternUtil.replace("abc123","%d+","#")`

<a id="playerutil--playercharacter"></a>
### PlayerUtil — player/character
- getPlayerFromCharacter(model: Instance) -> Player?
- getHumanoid(target: any) -> Humanoid?; getHRP(target: any) -> BasePart?
- waitForCharacter(player: Player, timeout?: number) -> Model?
- waitForHumanoid(target: Player|Model, timeout?: number) -> Humanoid?
- waitForHRP(target: Player|Model, timeout?: number) -> BasePart?
- isAlive(target: any) -> boolean
- Example: `Modules.PlayerUtil.getHumanoid(player)`

<a id="priorityqueue--min-heap"></a>
### PriorityQueue — min-heap
- new(lessFn?: (a:any,b:any)->boolean) -> PQ
- PQ:push(v); PQ:pop() -> any; PQ:peek() -> any; PQ:len() -> number
- Example: `Modules.PriorityQueue.new():push(1)`

<a id="promiseutil--promises"></a>
### PromiseUtil — Promises
- Promise.new(executor)
- :isSettled(); :andThen(onFulfilled?, onRejected?); :catch(onRejected); :finally(onFinally)
- resolve(value); reject(reason); delay(seconds, value?); all(list); race(list); timeout(promiseOrFn, seconds, timeoutErr?); retry(fn, attempts?, backoff?)
- Example: `Modules.PromiseUtil.resolve(5):andThen(print)`

<a id="randomutil--rng-convenience"></a>
### RandomUtil — RNG convenience
- new(seed?: number) -> RNG
- RNG:integer(min: number, max: number) -> number; RNG:number(min, max) -> number
- RNG:choice(list: {any}) -> any?; RNG:shuffle(list: {any}, inPlace?: boolean) -> {any}
- RNG:sample(list: {any}, k: number, unique?: boolean) -> {any}
- RNG:weighted(entries: { {item:any, weight:number} }) -> any
- RNG:bag(items: {any}) -> () -> any -- bag sampler
- Example: `Modules.RandomUtil.new():integer(1,10)`

<a id="ratelimiter--token-bucket"></a>
### RateLimiter — token bucket
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)
- Limiter:setCapacity(n: number); Limiter:setRefillPerSecond(n: number); Limiter:getState(key: string) -> { tokens:number, updated:number }
- Example: `Modules.RateLimiter.new(5,2):allow("shoot")`

<a id="raycastutil--raycast-helpers"></a>
### RaycastUtil — raycast helpers
- params(list?: {Instance}, mode?: "Include"|"Exclude") -> RaycastParams
- ignoreCharacter(params: RaycastParams, who: Player|Model|Humanoid)
- raycast(origin: Vector3, direction: Vector3, params?: RaycastParams) -> RaycastResult?
- raycastFromTo(a: Vector3, b: Vector3, params?: RaycastParams) -> RaycastResult?
- ground(position: Vector3, maxDistance?: number, params?: RaycastParams) -> RaycastResult?
- Example: `Modules.RaycastUtil.raycast(Vector3.new(), Vector3.new(0,-100,0))`

<a id="signal--lightweight-events"></a>
### Signal — lightweight events
- new() -> Signal
- Signal:Connect(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Once(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Fire(...: any)
- Signal:Wait() -> ...any
- Signal:Destroy()
- Example: `local s=Modules.Signal.new(); local c=s:Connect(print); s:Fire("hi"); c:Disconnect()`

<a id="soundutil--sound-helpers"></a>
### SoundUtil — sound helpers
- preload(list: {Sound|string|number})
- play(soundOrId: Sound|string|number, opts: { parent?: Instance, volume?: number, looped?: boolean, pitch?: number }) -> (Sound, { Stop: ()->(), FadeOut: (seconds:number)->() })
- Example: `Modules.SoundUtil.play(1843512685)`

<a id="statemachine--finite-state-machine"></a>
### StateMachine — finite state machine
- new(initial: string) -> FSM
- FSM:addState(name: string, def?: { onEnter?: (prev?, data?) -> (), onExit?: (next?, data?) -> () })
- FSM:can(target: string) -> boolean; FSM:transition(target: string, data?: any)
- FSM:destroy()
- Example: `Modules.StateMachine.new("Idle"):addState("Idle",{})`

<a id="statutil--stats-helpers"></a>
### StatUtil — stats helpers
- ema(prev: number?, x: number, alpha: number) -> number
- Running() -> { push: (number)->(), mean: ()->number, min: number, max: number, count: number }
- Example: `local r=Modules.StatUtil.Running(); r:push(1)`

<a id="stringutil--string-helpers"></a>
### StringUtil — string helpers
- ltrim(s: string) -> string; rtrim(s: string) -> string; trim(s: string) -> string
- split(s: string, sep: string, plain?: boolean) -> {string}; join(list: {string}, sep: string) -> string
- startsWith(s: string, prefix: string) -> boolean; endsWith(s: string, suffix: string) -> boolean
- capitalize(s: string) -> string; toTitleCase(s: string) -> string
- padLeft(s: string, len: number, ch?: string) -> string; padRight(s: string, len: number, ch?: string) -> string
- slugify(s: string) -> string; formatThousands(n: number) -> string
- Example: `Modules.StringUtil.trim("  hi  ")`

<a id="tableutil--table-helpers"></a>
### TableUtil — table helpers
- copy(t: any, deep?: boolean) -> any
- assign(target: table, ...) -> table
- mergeDeep(target: table, ...) -> table
- equals(a: any, b: any, deep?: boolean) -> boolean
- shallowEqual(a: any, b: any) -> boolean
- map(list: table, fn: (any, number) -> any) -> table
- filter(list: table, fn: (any, number) -> boolean) -> table
- find(list: table, fn: (any, number) -> boolean) -> any
- keys(t: table) -> table; values(t: table) -> table; isArray(t: any) -> boolean
- Example: `Modules.TableUtil.shallowEqual({a=1},{a=1})`

<a id="timeutil--time-formatting"></a>
### TimeUtil — time formatting
- nowUnix() -> number; formatDuration(seconds: number) -> string; humanize(seconds: number) -> string
- iso8601(epoch?: number) -> string; localISO(epoch?: number) -> string
- Example: `Modules.TimeUtil.formatDuration(90)`

<a id="timer--tiny-scheduler"></a>
### Timer — tiny scheduler
- wait(seconds: number)
- setTimeout(fn: () -> (), delaySeconds: number) -> { Stop: () -> () }
- setInterval(fn: () -> (), intervalSeconds: number) -> { Stop: () -> () }
- Example: `Modules.Timer.setTimeout(function() print("later") end,1)`

<a id="tweenutil--tween-numbersprops"></a>
### TweenUtil — tween numbers/props
- tween(target: Instance|number, info: TweenInfo, goalOrOnStep: table|((number)->())) -> Tween? 
- tweenAsync(instance: Instance, info: TweenInfo, goalProps: { [string]: any }) -> (boolean, string?)
- sequence(instance: Instance, steps: { {info: TweenInfo, goal: {[string]: any}, yield: boolean?} }) -> boolean
- Example: `Modules.TweenUtil.tweenAsync(someGui,TweenInfo.new(0.2),{Transparency=0.5})`

<a id="uuidutil--idsstrings"></a>
### UUIDUtil — ids/strings
- guid() -> string; randomString(length?: number, charset?: string) -> string; shortId(length?: number) -> string
- Example: `Modules.UUIDUtil.guid()`

<a id="vectorutil--vector3-helpers"></a>
### VectorUtil — Vector3 helpers
- clampMagnitude(v: Vector3, max: number) -> Vector3; horizontal(v) -> Vector3
- distance(a, b) -> number; distanceXZ(a, b) -> number
- project(a, onto) -> Vector3; reject(a, onto) -> Vector3; angleBetween(a, b) -> number
- fromYawPitch(yaw, pitch) -> Vector3; approximately(a, b, eps?) -> boolean; lerp(a, b, t) -> Vector3
- Example: `Modules.VectorUtil.clampMagnitude(Vector3.new(5,0,0),2)`

[Back to Shared](#shared-modules) · [Back to top](#table-of-contents)

---

<a id="client-modules"></a>
## Client modules

All available from the Client bundle (`Client.X`).

<details open>
<summary>Quick index</summary>

[ButtonFXUtil](#buttonfxutil--hoverpress-scale-fx) · [CameraUtil](#camerautil--camera-helpers) · [ClientRateLimiter](#clientratelimiter--client-side-limiter) · [CursorRayUtil](#cursorrayutil--screen-to-worldraycast) · [CursorUtil](#cursorutil--mouse-cursor) · [DeviceUtil](#deviceutil--device-info) · [GuiDragUtil](#guidragutil--draggable-frames) · [HapticUtil](#hapticutil--gamepad-rumble) · [HighlightUtil](#highlightutil--highlight-partsmodels) · [InputUtil](#inpututil--input-helpers) · [KeybindHintUtil](#keybindhintutil--keybind-hints) · [LayoutUtil](#layoututil--ui-layout-builders) · [ModalUtil](#modalutil--confirm-dialogs) · [NotificationQueue](#notificationqueue--queuedstacked-toasts) · [NotificationUtil](#notificationutil--quick-toasts) · [OffscreenIndicatorUtil](#offscreenindicatorutil--edge-arrows) · [ProgressBar](#progressbar--simple-progress-ui) · [ScreenFadeUtil](#screenfadeutil--fade-overlay) · [ScreenResizeUtil](#screenresizeutil--viewport-size-changes) · [ScreenShakeUtil](#screenshakeutil--camera-shake) · [ScrollUtil](#scrollutil--smooth-scroll) · [SliderUtil](#sliderutil--horizontal-slider) · [TooltipUtil](#tooltiputil--hover-tooltips) · [TouchGestureUtil](#touchgestureutil--panpinchrotate) · [ViewportUtil](#viewportutil--viewportframe-helpers)

</details>

<a id="buttonfxutil--hoverpress-scale-fx"></a>
### ButtonFXUtil — hover/press scale FX
- bind(button: GuiObject, options?: { hoverScale?: number, pressScale?: number, tween?: TweenInfo }) -> ()->()
- Example: `Client.ButtonFXUtil.bind(someButton)`

<a id="camerautil--camera-helpers"></a>
### CameraUtil — camera helpers
- setSubject(subject?: Instance)
- tweenTo(cf: CFrame, info: TweenInfo, focus?: Vector3)
- shake(duration: number, magnitude?: number, frequency?: number)
- Example: `Client.CameraUtil.tweenTo(CFrame.new(), TweenInfo.new(0.2))`

<a id="clientratelimiter--client-side-limiter"></a>
### ClientRateLimiter — client-side limiter
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)
- Example: `Client.ClientRateLimiter.new(4,2):allow("shoot")`

<a id="cursorrayutil--screen-to-worldraycast"></a>
### CursorRayUtil — screen-to-world/raycast
- screenPointToRay(point: Vector2, depth?: number) -> (Vector3 origin, Vector3 direction)
- mouseRay(depth?: number) -> (Vector3 origin, Vector3 direction)
- raycastFromScreenPoint(point: Vector2, params?: RaycastParams) -> RaycastResult?
- raycastMouse(params?: RaycastParams) -> RaycastResult?
- worldPointFromScreen(point: Vector2, depth: number) -> Vector3
- worldPointFromMouse(depth: number) -> Vector3
- Example: `Client.CursorRayUtil.raycastMouse()`

<a id="cursorutil--mouse-cursor"></a>
### CursorUtil — mouse cursor
- show(); hide(); setIcon(icon: string)
- lockCenter(enable: boolean); isLocked() -> boolean
- Example: `Client.CursorUtil.setIcon("rbxassetid://123")`

<a id="deviceutil--device-info"></a>
### DeviceUtil — device info
- viewport() -> Vector2; platform() -> string; isSmallScreen() -> boolean; safeAreaInset() -> Vector2
- Example: `Client.DeviceUtil.platform()`

<a id="guidragutil--draggable-frames"></a>
### GuiDragUtil — draggable frames
- attach(frame: GuiObject, opts?: { clampToScreen?: boolean, sensitivity?: number }) -> ()->()
- Example: `Client.GuiDragUtil.attach(someFrame)`

<a id="hapticutil--gamepad-rumble"></a>
### HapticUtil — gamepad rumble
- rumble(gamepad: Enum.UserInputType, intensity: number, duration: number)
- rumbleAll(intensity: number, duration: number)
- Example: `Client.HapticUtil.rumble(Enum.UserInputType.Gamepad1,0.7,0.2)`

<a id="highlightutil--highlight-partsmodels"></a>
### HighlightUtil — highlight parts/models
- show(target: Instance, options?: { color?: Color3, fill?: number, outline?: number, duration?: number }) -> (Highlight, ()->())
- Example: `Client.HighlightUtil.show(workspace.Part)`

<a id="inpututil--input-helpers"></a>
### InputUtil — input helpers
- bindAction(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- bindOnce(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- onKey(keyCode: Enum.KeyCode, fn: (pressed:boolean)->()) -> RBXScriptConnection
- isTouch() -> boolean; isGamepad() -> boolean; isKeyboardMouse() -> boolean
- Example: `Client.InputUtil.bindOnce("Do", print, true, {Enum.KeyCode.F})`

<a id="keybindhintutil--keybind-hints"></a>
### KeybindHintUtil — keybind hints
- show(options: { key: string, text: string, position?: UDim2 }) -> string|number
- remove(id: string|number)
- Example: `Client.KeybindHintUtil.show({key="E",text="Interact"})`

<a id="layoututil--ui-layout-builders"></a>
### LayoutUtil — UI layout builders
- createList(options?: { parent?: Instance, padding?: UDim, fill?: boolean, align?: Enum.HorizontalAlignment }) -> UIListLayout
- createGrid(options?: { parent?: Instance, cellSize?: UDim2, cellPadding?: UDim2 }) -> UIGridLayout
- createTable(options?: { parent?: Instance, padding?: UDim }) -> UITableLayout
- createPadding(options?: { parent?: Instance, left?: UDim, right?: UDim, top?: UDim, bottom?: UDim }) -> UIPadding
- Example: `Client.LayoutUtil.createList({parent=someContainer})`

<a id="modalutil--confirm-dialogs"></a>
### ModalUtil — confirm dialogs
- confirm(opts: { title?: string, message?: string, buttons?: {string} }) -> Promise<string>
- Example: `Client.ModalUtil.confirm({title="OK"}):andThen(print)`

<a id="notificationqueue--queuedstacked-toasts"></a>
### NotificationQueue — queued/stacked toasts
- new(opts?: { maxVisible?: number, gap?: number, position?: UDim2, anchor?: Vector2 }) -> Queue
- Queue:destroy(); Queue:setMaxVisible(n: number); Queue:setGap(px: number)
- Queue:setPosition(pos: UDim2, anchor?: Vector2); Queue:clear()
- Queue:show(text: string, opts?); Queue:enqueue(text: string, opts?)
- Example: `Client.NotificationQueue.new():enqueue("Hello")`

<a id="notificationutil--quick-toasts"></a>
### NotificationUtil — quick toasts
- show(text: string, opts: { duration?: number, stroke?: boolean, position?: UDim2, anchor?: Vector2 })
- Example: `Client.NotificationUtil.show("Saved!",{duration=1})`

<a id="offscreenindicatorutil--edge-arrows"></a>
### OffscreenIndicatorUtil — edge arrows
- attach(target: Instance, options?: { margin?: number, color?: Color3 }) -> ()->()
- Example: `Client.OffscreenIndicatorUtil.attach(workspace.Part)`

<a id="progressbar--simple-progress-ui"></a>
### ProgressBar — simple progress UI
- create(parent?: Instance, opts?: { size?: UDim2, position?: UDim2, corner?: number, theme?: {bg:Color3, fill:Color3, text:Color3} }) -> Bar
- Bar:SetProgress(alpha: number, tweenSeconds?: number)
- Bar:SetText(text?: string); Bar:Show(); Bar:Hide(); Bar:Destroy()
- Example: `Client.ProgressBar.create(script.Parent):SetProgress(0.5,0.2)`

<a id="screenfadeutil--fade-overlay"></a>
### ScreenFadeUtil — fade overlay
- fadeIn(duration: number, color?: Color3, transparency?: number)
- fadeOut(duration: number)
- flash(duration: number)
- Example: `Client.ScreenFadeUtil.fadeIn(0.25)`

<a id="screenresizeutil--viewport-size-changes"></a>
### ScreenResizeUtil — viewport size changes
- onResize(handler: (Vector2)->()) -> RBXScriptConnection
- getViewportSize() -> Vector2
- Example: `Client.ScreenResizeUtil.onResize(print)`

<a id="screenshakeutil--camera-shake"></a>
### ScreenShakeUtil — camera shake
- start(params: { amplitude: number, frequency: number, duration: number, decay?: boolean }) -> ()->()
- Example: `Client.ScreenShakeUtil.start({amplitude=1,frequency=10,duration=0.5})`

<a id="scrollutil--smooth-scroll"></a>
### ScrollUtil — smooth scroll
- smoothScrollTo(scroller: ScrollingFrame, target: Vector2, tweenInfo?: TweenInfo)
- scrollBy(scroller: ScrollingFrame, dx: number, dy: number, tweenInfo?: TweenInfo)
- Example: `Client.ScrollUtil.smoothScrollTo(someScrollingFrame, Vector2.new(0,200))`

<a id="sliderutil--horizontal-slider"></a>
### SliderUtil — horizontal slider
- create(options: { parent?: Instance, width?: number, initial?: number }) -> Slider
- Slider.OnChanged(value: number) (Signal); Slider:SetValue(value: number)
- Example: `Client.SliderUtil.create({parent=script.Parent})`

<a id="tooltiputil--hover-tooltips"></a>
### TooltipUtil — hover tooltips
- bind(guiObject: GuiObject, options: { text: string, delay?: number, offset?: Vector2 }) -> ()->()
- Example: `Client.TooltipUtil.bind(someButton,{text="Hi"})`

<a id="touchgestureutil--panpinchrotate"></a>
### TouchGestureUtil — pan/pinch/rotate
- bind(options?: { minPinch?: number, minRotate?: number }) -> Controller
- Controller.OnPan(delta: Vector2); Controller.OnPinch(delta: number); Controller.OnRotate(radians: number)
- Controller:Destroy()
- Example: `Client.TouchGestureUtil.bind()`

<a id="viewportutil--viewportframe-helpers"></a>
### ViewportUtil — ViewportFrame helpers
- createViewport(size: UDim2, bg?: Color3) -> ViewportFrame
- setModel(vpf: ViewportFrame, model: Model, opts?: { cameraCFrame?: CFrame, distance?: number })
- Example: `Client.ViewportUtil.createViewport(UDim2.fromOffset(200,200))`

[Back to Client](#client-modules) · [Back to top](#table-of-contents)

---

<a id="server-modules"></a>
## Server modules

All available from the Server bundle (`Server.X`).

<details open>
<summary>Quick index</summary>

[AccessControlUtil](#accesscontrolutil--feature-gates) · [AllowlistUtil](#allowlistutil--join-access) · [AuditLogUtil](#auditlogutil--batched-logging) · [BadgeUtil](#badgeutil--badges) · [BanUtil](#banutil--bans) · [CharacterAppearanceUtil](#characterappearanceutil--outfitscolorsaccessories) · [CharacterHealthUtil](#characterhealthutil--healthinvulnerability) · [CharacterMovementUtil](#charactermovementutil--movement-properties) · [CharacterScaleUtil](#characterscaleutil--r15-scaling) · [CharacterVisibilityUtil](#charactervisibilityutil--transparencyghost) · [ChatFilterUtil](#chatfilterutil--text-filter) · [CrossServerEvent](#crossserverevent--cross-server-events) · [DataStoreUtil](#datastoreutil--datastore-helpers) · [DistributedLockUtil](#distributedlockutil--distributed-locks) · [GlobalRateLimiter](#globalratelimiter--distributed-token-bucket) · [GroupUtil](#grouputil--group-info) · [HttpUtil](#httputil--http-requests) · [JobScheduler](#jobscheduler--background-jobs) · [LeaderstatsUtil](#leaderstatsutil--leaderstats) · [LockdownUtil](#lockdownutil--server-lockdown) · [MaintenanceAnnouncer](#maintenanceannouncer--scheduled-maintenance) · [MarketplaceUtil](#marketplaceutil--purchases) · [MatchmakingUtil](#matchmakingutil--queueparty-matching) · [MemoryStoreUtil](#memorystoreutil--queuesmaps) · [MessagingServiceUtil](#messagingserviceutil--pubsub) · [PlayerBanEnforcer](#playerbanenforcer--auto-kick-banned) · [PlayerProfileUtil](#playerprofileutil--player-profiles) · [PlayerSessionUtil](#playersessionutil--player-sessions) · [PolicyUtil](#policyutil--policy-checks) · [ServerHeartbeat](#serverheartbeat--liveness-heartbeat) · [ServerMetricsUtil](#servermetricsutil--server-metrics) · [ServerRegistry](#serverregistry--list-active-servers) · [ShutdownUtil](#shutdownutil--graceful-shutdown) · [TeleportUtil](#teleportutil--teleports) · [WebhookUtil](#webhookutil--json-webhooks)

</details>

<a id="accesscontrolutil--feature-gates"></a>
### AccessControlUtil — feature gates
<a id="allowlistutil--join-access"></a>
### AllowlistUtil — join access
- new(opts?: { mode?: "open"|"allowlist"|"denylist", kickMessage?: string, storeName?: string, scope?: string, dryRun?: boolean }) -> Gate
- Gate:setMode(mode: string)
- Gate:add(userId: number); Gate:remove(userId: number)
- Gate:deny(userId: number); Gate:undeny(userId: number)
- Gate:isAllowed(player: Player) -> boolean
- Gate:bind() -> ()->() — auto-kick disallowed on join (no-op in dryRun)
- Example: `local g=Server.AllowlistUtil.new({mode="allowlist"}); g:add(123); g:bind()`

- canUseFeature(player: Player, rules: { allowUserIds?: {number}, denyUserIds?: {number}, group?: { id: number, minRank?: number }, gamePassId?: number, requireVoice?: boolean, forbidPaidRandomItems?: boolean }, deps?: { PolicyUtil?: any, GroupUtil?: any, MarketplaceUtil?: any }) -> (boolean, string?)
- Example: `Server.AccessControlUtil.canUseFeature(player,{requireVoice=true})`

<a id="auditlogutil--batched-logging"></a>
### AuditLogUtil — batched logging
- new(url: string, opts?: { batchSize?: number, flushInterval?: number }) -> Logger
- Logger:setDestination(url: string)
- Logger:log(eventName: string, fields?: table)
- Logger:start(); Logger:stop()
- Example: `Server.AuditLogUtil.new("https://example.com/log")`

<a id="badgeutil--badges"></a>
### BadgeUtil — badges
- hasBadge(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, boolean|any)
- awardIfNotOwned(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, any)
- Example: `Server.BadgeUtil.awardIfNotOwned(player,123456)`

<a id="banutil--bans"></a>
### BanUtil — bans
- ban(userIdOrPlayer: number|Player, reason?: string, durationSeconds?: number, by?: string) -> (boolean, any)
- unban(userIdOrPlayer: number|Player) -> (boolean, any)
- getBan(userIdOrPlayer: number|Player) -> ({ reason?: string, expiresAt?: number, by?: string }?|nil, any)
- isBanned(userIdOrPlayer: number|Player) -> boolean
- shouldKick(player: Player) -> (boolean, string?)
- Example: `Server.BanUtil.shouldKick(player)`

<a id="characterappearanceutil--outfitscolorsaccessories"></a>
### CharacterAppearanceUtil — outfits/colors/accessories
- applyDescription(target: Player|Model|Humanoid, description: HumanoidDescription) -> (boolean, string?)
- applyUserOutfit(target: Player|Model|Humanoid, userId: number) -> (boolean, string?)
- applyOutfitId(target: Player|Model|Humanoid, outfitId: number) -> (boolean, string?)
- setBodyColors(targetOrCharacter: Player|Model|Humanoid, colors?: { Head?: BrickColor|Color3|string, LeftArm?: BrickColor|Color3|string, RightArm?: BrickColor|Color3|string, LeftLeg?: BrickColor|Color3|string, RightLeg?: BrickColor|Color3|string, Torso?: BrickColor|Color3|string }) -> BodyColors|nil, string?
- addAccessory(target: Player|Model|Humanoid, accessory: Accessory) -> (boolean, string?)
- removeAccessories(target: Player|Model|Humanoid, predicate?: (Accessory)->boolean) -> (number|false, string?)
- setClothingIds(target: Player|Model|Humanoid, shirtId?: number|string, pantsId?: number|string) -> (boolean, string?)
- Example: `Server.CharacterAppearanceUtil.setBodyColors(model,{Head=BrickColor.new("Bright yellow")})`

<a id="characterhealthutil--healthinvulnerability"></a>
### CharacterHealthUtil — health/invulnerability
- setMaxHealth(target: Player|Model|Humanoid, maxHealth: number, options?: { clamp?: boolean }) -> (boolean, string?)
- heal(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- damage(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- setInvulnerable(target: Player|Model|Humanoid, enabled: boolean, options?: { duration?: number }) -> (boolean, (() -> ())?)
- Example: `Server.CharacterHealthUtil.setInvulnerable(humanoid,true)`

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
- Example: `Server.CharacterMovementUtil.setWalkSpeed(humanoid,24)`

<a id="characterscaleutil--r15-scaling"></a>
### CharacterScaleUtil — R15 scaling
- getScales(target: Player|Model|Humanoid) -> { height: number, width: number, depth: number, head: number }
- setScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, options?: { clamp?: boolean }) -> (boolean, string?)
- setUniformScale(target: Player|Model|Humanoid, scale: number, options?: { clamp?: boolean }) -> (boolean, string?)
- tweenScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- tweenUniformScale(target: Player|Model|Humanoid, scale: number, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- reset(target: Player|Model|Humanoid) -> (boolean, string?)
- Example: `Server.CharacterScaleUtil.setUniformScale(humanoid,1.1)`

<a id="charactervisibilityutil--transparencyghost"></a>
### CharacterVisibilityUtil — transparency/ghost
- setTransparency(target: Player|Model|Humanoid, alpha: number, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setInvisible(target: Player|Model|Humanoid, enabled: boolean, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setGhostMode(target: Player|Model|Humanoid, enabled: boolean) -> (boolean, string?)
- Example: `Server.CharacterVisibilityUtil.setInvisible(model,true)`

<a id="chatfilterutil--text-filter"></a>
### ChatFilterUtil — text filter
- filterForBroadcast(text: string, fromUserId: number) -> (boolean, string|any)
- filterForUser(text: string, fromUserId: number, toUserId: number) -> (boolean, string|any)
- Example: `Server.ChatFilterUtil.filterForBroadcast("hi",player.UserId)`

<a id="crossserverevent--cross-server-events"></a>
### CrossServerEvent — cross-server events
- new(prefix?: string) -> CSE
- CSE:publish(eventName: string, data: any) -> (boolean, any)
- CSE:subscribe(eventName: string, handler: (data:any)->()) -> { Disconnect: ()->() }
- CSE:destroy()
- Example: `local bus=Server.CrossServerEvent.new("uf"); bus:publish("Announce",{msg="hi"})`

<a id="datastoreutil--datastore-helpers"></a>
### DataStoreUtil — DataStore helpers
- getStore(name: string, scope?: string) -> DataStore
- waitForBudget(type: Enum.DataStoreRequestType, min?: number, timeout?: number) -> boolean
- get(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, value?: any, err?: string)
- set(store: GlobalDataStore, key: string, value: any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)
- update(store: GlobalDataStore, key: string, fn: (old:any)->any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: any, err?: string)
- increment(store: GlobalDataStore, key: string, delta: number, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: number, err?: string)
- remove(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)
- Example: `local s=Server.DataStoreUtil.getStore("UF"); Server.DataStoreUtil.set(s,"k",123)`

<a id="distributedlockutil--distributed-locks"></a>
### DistributedLockUtil — distributed locks
- acquire(key: string, ttlSeconds?: number) -> (ok: boolean, tokenOrErr: string)
- renew(key: string, token: string, ttlSeconds?: number) -> (ok: boolean, err?: string)
- release(key: string, token: string) -> (ok: boolean, err?: string)
- Example: `Server.DistributedLockUtil.acquire("k",5)`

<a id="globalratelimiter--distributed-token-bucket"></a>
### GlobalRateLimiter — distributed token bucket
- new(capacity: number, refillPerSecond: number) -> GRL
- GRL:allow(key: string, tokens?: number) -> (ok: boolean, remaining: number)
- GRL:setCapacity(n: number); GRL:setRefillPerSecond(n: number)
- Example: `Server.GlobalRateLimiter.new(5,2):allow("key")`

<a id="grouputil--group-info"></a>
### GroupUtil — group info
- getRoleInGroup(userIdOrPlayer: number|Player, groupId: number) -> (string?|nil, string?|nil)
- getRankInGroup(userIdOrPlayer: number|Player, groupId: number) -> (number, string?|nil)
- isInGroup(userIdOrPlayer: number|Player, groupId: number, minRank?: number) -> boolean
- Example: `Server.GroupUtil.getRankInGroup(player,12345)`

<a id="httputil--http-requests"></a>
### HttpUtil — HTTP requests
- request(opts: { method: string, url: string, headers?: table, body?: string|table, json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res: { StatusCode: number, Success: boolean, Headers: table, Body: string, Json?: any }?, err?: string)
- get(url: string, headers?: table, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- post(url: string, body: any, headers?: table, opts?: { json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- fetchJson(url: string, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, json?: any, err?: string)
- encode(value: any) -> string; decode(str: string) -> any
- Example: `Server.HttpUtil.get("https://httpbin.org/get")`

<a id="jobscheduler--background-jobs"></a>
### JobScheduler — background jobs
- new(name: string, opts?: { visibility?: number, poll?: number }) -> Scheduler
- Scheduler:enqueue(payload: any, ttl?: number) -> (boolean, any)
- Scheduler:startWorker(handler: (payload: any, entry: { Id: string, Value: any })->())
- Scheduler:stopWorker()
- Example: `Server.JobScheduler.new("uf",{poll=1})`

<a id="leaderstatsutil--leaderstats"></a>
### LeaderstatsUtil — leaderstats
<a id="lockdownutil--server-lockdown"></a>
### LockdownUtil — server lockdown
- new(opts?: { topic?: string, kickMessage?: string, storeName?: string, scope?: string, dryRun?: boolean }) -> Lockdown
- Lockdown:bind() -> ()->() — auto-kick (delegates to AllowlistUtil)
- Lockdown:enable(reason?: string); Lockdown:disable(); Lockdown:isEnabled() -> boolean
- Lockdown:allow(userId: number); Lockdown:deny(userId: number); Lockdown:isAllowed(player: Player) -> boolean
- Example: `local l=Server.LockdownUtil.new({storeName="UF_Gates"}); l:bind(); l:enable("Maintenance")`

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
- Example: `Server.LeaderstatsUtil.addInt(player,"Coins",0)`

<a id="maintenanceannouncer--scheduled-maintenance"></a>
### MaintenanceAnnouncer — scheduled maintenance
- new(maintenanceUnix: number, opts?: { topic?: string, reminders?: {number}, kickAtEnd?: boolean }) -> Announcer
- Announcer:announce(text: string) — broadcast immediately via MessagingService topic
- Announcer:start() — schedule reminders and final action
- Announcer:stop() — stop further reminders (best-effort)
- Example: `local t=os.time()+300; local a=Server.MaintenanceAnnouncer.new(t,{kickAtEnd=false}); a:start()`

<a id="marketplaceutil--purchases"></a>
### MarketplaceUtil — purchases
- ownsGamePass(player: Player, gamePassId: number) -> (boolean, boolean|any)
- promptGamePass(player: Player, gamePassId: number)
- promptProduct(player: Player, productId: number)
- createReceiptRouter(map: { [productId: number]: (player: Player, receiptInfo: any) -> Enum.ProductPurchaseDecision }) -> (receiptInfo: any) -> Enum.ProductPurchaseDecision
- bindProcessReceipt(fn: (receiptInfo: any) -> Enum.ProductPurchaseDecision)
- Example: `Server.MarketplaceUtil.ownsGamePass(player,123)`

<a id="matchmakingutil--queueparty-matching"></a>
### MatchmakingUtil — queue/party matching
- new(placeId: number, partySize: number, opts?: {
		retries?: number, backoff?: number, pollSeconds?: number,
		priorityAgingPerSecond?: number, dryRun?: boolean,
		teleportStrategy?: "private"|"public", serverSelector?: (({Player})->(string?)),
		constraints?: { groupBy?: string|((entry)->any), requireRoles?: { [string]: number }, predicate?: (entry)->boolean, compatibility?: (a,b)->boolean }
	}) -> MM
- MM:enqueue(player: Player, opts?: { priority?: number, role?: string, region?: string, timeoutSec?: number, meta?: table })
- MM:dequeue(player: Player); MM:size() -> number; MM:flush(); MM:destroy()
- MM:onMatched(cb: ({Player})->()) -> RBXScriptConnection
- MM:onTimeout(cb: (Player)->()) -> RBXScriptConnection
- Example: `local mm=Server.MatchmakingUtil.new(game.PlaceId,2,{constraints={groupBy="region",requireRoles={Tank=1,Healer=1}}, priorityAgingPerSecond=0.01}); mm:enqueue(player,{role="Tank",region="NA"})`

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
- Example: `Server.MemoryStoreUtil.queue("jobs")`

<a id="messagingserviceutil--pubsub"></a>
### MessagingServiceUtil — pub/sub
- publish(topic: string, data: any, opts?: { retries?: number, backoff?: number }) -> (boolean, any)
- subscribe(topic: string, handler: (data:any, message:any)->(), opts?: { safe?: boolean }) -> { Disconnect: ()->() }
- Example: `Server.MessagingServiceUtil.publish("uf:news",{hello=true})`

<a id="policyutil--policy-checks"></a>
### PolicyUtil — policy checks
- getPolicy(player: Player) -> (table?|nil, string?|nil)
- arePaidRandomItemsRestricted(player: Player) -> boolean?|nil
- isSubjectToChinaPolicies(player: Player) -> boolean?|nil
- isVoiceEnabled(player: Player) -> boolean?|nil
- Example: `Server.PolicyUtil.isVoiceEnabled(player)`

<a id="playerbanenforcer--auto-kick-banned"></a>
### PlayerBanEnforcer — auto-kick banned
- new() -> Enforcer
- Enforcer:bind() -> ()->() — kick banned players on join using BanUtil.shouldKick
- Example: `local e=Server.PlayerBanEnforcer.new(); e:bind()`

<a id="playersessionutil--player-sessions"></a>
### PlayerSessionUtil — player sessions
<a id="playerprofileutil--player-profiles"></a>
### PlayerProfileUtil — player profiles
- new(storeName: string, template: table, opts?: { lockTtl?: number, saveOnLeave?: boolean, dryRun?: boolean, keyFn?: (Player)->string }) -> Profiles
- Profiles:onLoaded((player: Player, data: table)->()) -> RBXScriptConnection
- Profiles:onSaving((player: Player, data: table)->()) -> RBXScriptConnection
- Profiles:onReleased((player: Player, data: table)->()) -> RBXScriptConnection
- Profiles:bind() -> ()->() — acquire on join, release on leave
- Profiles:get(player: Player) -> table?; Profiles:save(player: Player) -> (boolean, string?)
- Example: `local p=Server.PlayerProfileUtil.new("UF_Profiles",{Coins=0},{lockTtl=30}); p:bind()`

- new() -> Tracker
- Tracker:bind() -> ()->() — start tracking Players join/leave
- Tracker:get(player: Player) -> { startedAt: number, lastSeen: number, durationSec: ()->number }?
- Tracker:onStart((player: Player, session: table)->()) -> RBXScriptConnection
- Tracker:onEnd((player: Player, session: table)->()) -> RBXScriptConnection
- Tracker:destroy()
- Example: `local t=Server.PlayerSessionUtil.new(); t:bind()`

<a id="servermetricsutil--server-metrics"></a>
### ServerMetricsUtil — server metrics
- snapshot() -> { serverTime: number, uptimeSec: number, players: number, jobId: string, placeId: number, private: boolean, memoryMB: number }
- publishToTopic(topic: string) -> (ok: boolean, err?: string)
- Example: `Server.ServerMetricsUtil.snapshot()`

<a id="serverheartbeat--liveness-heartbeat"></a>
### ServerHeartbeat — liveness heartbeat
- new(name?: string, ttlSeconds?: number) -> HB
- HB:start(intervalSeconds?: number)
- HB:stop()
- Example: `local hb=Server.ServerHeartbeat.new("uf:hb",60); hb:start(15)`

<a id="serverregistry--list-active-servers"></a>
### ServerRegistry — list active servers
- new(name?: string) -> Registry
- Registry:listActive(maxAgeSec?: number, limit?: number) -> { { jobId: string, placeId: number, ts: number, players: number, private: boolean } }
- Example: `local r=Server.ServerRegistry.new("uf:hb"); local list=r:listActive(120,50)`

<a id="shutdownutil--graceful-shutdown"></a>
### ShutdownUtil — graceful shutdown
- onShutdown(fn: ()->()) -> ()->() -- register callback for BindToClose
- setTimeout(seconds: number) — max time to run callbacks in BindToClose
- bind() — attach BindToClose once
- initiate(reason?: string) — run callbacks now and kick players (does not close the server)
- Example: `Server.ShutdownUtil.onShutdown(function() print("Saving...") end); Server.ShutdownUtil.bind()`

<a id="teleportutil--teleports"></a>
### TeleportUtil — teleports
- teleportInServer(target: Player|Model, destination: CFrame|Vector3|BasePart, options?: { keepOrientation?: boolean, offset?: Vector3, unseat?: boolean }) -> boolean
- teleportToPlace(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- teleportToPlaceInstance(placeId: number, jobId: string, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- reserveServer(placeId: number) -> (string accessCode, string reservedServerId)
- teleportToPrivateServer(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean ok, string? errMsg, string? accessCode)
- Example: `Server.TeleportUtil.teleportInServer(player, workspace.SpawnLocation)`

<a id="webhookutil--json-webhooks"></a>
### WebhookUtil — JSON webhooks
- postJson(url: string, payload: table, opts?: { headers?: table, compress?: boolean, httpService?: HttpService }) -> (boolean, any)
- Example: `Server.WebhookUtil.postJson("https://example.com",{hello="world"})`

[Back to Server](#server-modules) · [Back to top](#table-of-contents)

---

<a id="usage-notes"></a>
## Usage notes
- Prefer bundle requires; they export all modules as fields.
- Server-only modules must be required on the server.
- For practical examples, see `Tests/AllModules.client.lua` and `Tests/AllModules.server.lua`.
