# Useful Functions — API Reference

A compact, practical API index for all modules. Grouped by bundle:

- Shared (client + server): `local Modules = require(ReplicatedStorage.UsefulFunctions)`
- Client-only: `local Client = require(ReplicatedStorage.UsefulFunctionsClient)`
- Server-only: `local Server = require(ServerScriptService.UsefulFunctions.UsefulFunctionsServer)`

Tip: In Studio, individual modules are also mapped under ReplicatedStorage/ServerScriptService for convenience, but bundle requires are recommended.

## Table of contents

- [Shared modules](#shared-modules)
	- [Signal](#signal--lightweight-events)
	- [Maid](#maid--cleanup-aggregator)
	- [Debounce](#debounce--debouncethrottle)
	- [Timer](#timer--tiny-scheduler)
	- [TweenUtil](#tweenutil--tween-numbersprops)
	- [InstanceUtil](#instanceutil--instance-helpers)
	- [TableUtil](#tableutil--table-helpers)
	- [StringUtil](#stringutil--string-helpers)
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

## Shared modules

All available from the Shared bundle (`Modules.X`).

### Signal — lightweight events
- new() -> Signal
- Signal:Connect(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Once(fn: (...any) -> ()) -> RBXScriptConnection
- Signal:Fire(...: any)
- Signal:Wait() -> ...any
- Signal:Destroy()
- Example: `local sig = Modules.Signal.new(); local c = sig:Connect(print); sig:Fire("hi")`

### Maid — cleanup aggregator
- new() -> Maid
- Maid:GiveTask(task: Instance|RBXScriptConnection|() -> ())
- Maid:Cleanup()
- Maid:DoCleaning() -- alias
- Maid:Destroy()
- Example: `local m = Modules.Maid.new(); m:GiveTask(conn); m:Cleanup()`

### Debounce — debounce/throttle
- debounce(fn: (...any) -> (), waitSeconds: number) -> (...any) -> ()
- throttle(fn: (...any) -> (), intervalSeconds: number) -> (...any) -> ()

### Timer — tiny scheduler
- wait(seconds: number)
- setTimeout(fn: () -> (), delaySeconds: number) -> { Stop: () -> () }
- setInterval(fn: () -> (), intervalSeconds: number) -> { Stop: () -> () }

### TweenUtil — tween numbers/props
- tween(target: Instance|number, info: TweenInfo, goalOrOnStep: table|((number)->())) -> Tween? 
- tweenAsync(instance: Instance, info: TweenInfo, goalProps: { [string]: any }) -> (boolean, string?)
- sequence(instance: Instance, steps: { {info: TweenInfo, goal: {[string]: any}, yield: boolean?} }) -> boolean

### InstanceUtil — instance helpers
- create(className: string, props?: table, children?: {Instance}) -> Instance
- getOrCreate(parent: Instance, className: string, name?: string) -> Instance
- waitForDescendant(parent: Instance, name: string, timeoutSeconds?: number) -> Instance?
- destroyChildren(parent: Instance, predicate?: (Instance) -> boolean)
- cloneInto(source: Instance, parent: Instance, props?: table) -> Instance

### TableUtil — table helpers
- copy(t: any, deep?: boolean) -> any
- assign(target: table, ...) -> table
- mergeDeep(target: table, ...) -> table
- equals(a: any, b: any, deep?: boolean) -> boolean
- map(list: table, fn: (any, number) -> any) -> table
- filter(list: table, fn: (any, number) -> boolean) -> table
- find(list: table, fn: (any, number) -> boolean) -> any
- keys(t: table) -> table; values(t: table) -> table; isArray(t: any) -> boolean

### StringUtil — string helpers
- ltrim(s: string) -> string; rtrim(s: string) -> string; trim(s: string) -> string
- split(s: string, sep: string, plain?: boolean) -> {string}; join(list: {string}, sep: string) -> string
- startsWith(s: string, prefix: string) -> boolean; endsWith(s: string, suffix: string) -> boolean
- capitalize(s: string) -> string; toTitleCase(s: string) -> string
- padLeft(s: string, len: number, ch?: string) -> string; padRight(s: string, len: number, ch?: string) -> string
- slugify(s: string) -> string; formatThousands(n: number) -> string

### MathUtil — math helpers
- clamp(n, minV, maxV) -> number; lerp(a, b, t) -> number; invLerp(a, b, v) -> number
- remap(v, inMin, inMax, outMin, outMax, doClamp?) -> number
- round(n, decimals?) -> number; roundTo(n, increment) -> number; floorTo(n, increment) -> number; ceilTo(n, increment) -> number
- approxEqual(a, b, eps?) -> boolean; randomRange(min, max, integer?) -> number
- chooseWeighted(entries: { {item:any, weight:number} }) -> any

### CFrameUtil — CFrame helpers
- lookAt(origin: Vector3, target: Vector3, up?: Vector3) -> CFrame
- fromYawPitchRoll(y, p, r) -> CFrame; toYawPitchRoll(cf: CFrame) -> (number, number, number)
- rotateAround(cf: CFrame, origin: Vector3, axisUnit: Vector3, radians: number) -> CFrame
- offset(cf: CFrame, delta: Vector3) -> CFrame; clampYaw(cf: CFrame, minYaw: number, maxYaw: number) -> CFrame

### VectorUtil — Vector3 helpers
- clampMagnitude(v: Vector3, max: number) -> Vector3; horizontal(v) -> Vector3
- distance(a, b) -> number; distanceXZ(a, b) -> number
- project(a, onto) -> Vector3; reject(a, onto) -> Vector3; angleBetween(a, b) -> number
- fromYawPitch(yaw, pitch) -> Vector3; approximately(a, b, eps?) -> boolean; lerp(a, b, t) -> Vector3

### RaycastUtil — raycast helpers
- params(list?: {Instance}, mode?: "Include"|"Exclude") -> RaycastParams
- ignoreCharacter(params: RaycastParams, who: Player|Model|Humanoid)
- raycast(origin: Vector3, direction: Vector3, params?: RaycastParams) -> RaycastResult?
- raycastFromTo(a: Vector3, b: Vector3, params?: RaycastParams) -> RaycastResult?
- ground(position: Vector3, maxDistance?: number, params?: RaycastParams) -> RaycastResult?

### ColorUtil — Color3 helpers
- fromHex(hex: string) -> Color3; toHex(c: Color3) -> string
- fromRGB(r,g,b) -> Color3; toRGB(c: Color3) -> (number, number, number)
- lerp(a: Color3, b: Color3, t: number) -> Color3; lighten(c: Color3, factor: number) -> Color3; darken(c: Color3, factor: number) -> Color3

### CollectionUtil — CollectionService tags
- addTag(inst: Instance, tag: string)
- removeTag(inst: Instance, tag: string)
- hasTag(inst: Instance, tag: string) -> boolean
- getTagged(tag: string) -> {Instance}
- onAdded(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- onRemoved(tag: string, callback: (Instance) -> ()) -> RBXScriptConnection
- watchTag(tag: string, onAdded: (Instance)->(), onRemoved?: (Instance)->()) -> () -> ()

### TimeUtil — time formatting
- nowUnix() -> number; formatDuration(seconds: number) -> string; humanize(seconds: number) -> string
- iso8601(epoch?: number) -> string; localISO(epoch?: number) -> string

### PatternUtil — Lua pattern utils
- escapePattern(s: string) -> string
- findAll(s: string, pattern: string, init?: number) -> { [number]: { start:number, finish:number, captures:{any} } }
- matchAll(s: string, pattern: string) -> {any}
- replace(s: string, pattern: string, repl: any, n?: number) -> (string, number)
- count(s: string, pattern: string) -> number
- splitByPattern(s: string, pattern: string) -> {string}
- startsWithPattern(s: string, pattern: string) -> boolean; endsWithPattern(s: string, pattern: string) -> boolean
- wildcardToPattern(glob: string) -> string

### PromiseUtil — Promises
- Promise.new(executor)
- :isSettled(); :andThen(onFulfilled?, onRejected?); :catch(onRejected); :finally(onFinally)
- resolve(value); reject(reason); delay(seconds, value?); all(list); race(list); timeout(promiseOrFn, seconds, timeoutErr?); retry(fn, attempts?, backoff?)

### PlayerUtil — player/character
- getPlayerFromCharacter(model: Instance) -> Player?
- getHumanoid(target: any) -> Humanoid?; getHRP(target: any) -> BasePart?
- waitForCharacter(player: Player, timeout?: number) -> Model?
- waitForHumanoid(target: Player|Model, timeout?: number) -> Humanoid?
- waitForHRP(target: Player|Model, timeout?: number) -> BasePart?
- isAlive(target: any) -> boolean

### SoundUtil — sound helpers
- preload(list: {Sound|string|number})
- play(soundOrId: Sound|string|number, opts: { parent?: Instance, volume?: number, looped?: boolean, pitch?: number }) -> (Sound, { Stop: ()->(), FadeOut: (seconds:number)->() })

### RandomUtil — RNG convenience
- new(seed?: number) -> RNG
- RNG:integer(min: number, max: number) -> number; RNG:number(min, max) -> number
- RNG:choice(list: {any}) -> any?; RNG:shuffle(list: {any}, inPlace?: boolean) -> {any}
- RNG:sample(list: {any}, k: number, unique?: boolean) -> {any}
- RNG:weighted(entries: { {item:any, weight:number} }) -> any
- RNG:bag(items: {any}) -> () -> any -- bag sampler

### RateLimiter — token bucket
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)
- Limiter:setCapacity(n: number); Limiter:setRefillPerSecond(n: number); Limiter:getState(key: string) -> { tokens:number, updated:number }

### StateMachine — finite state machine
- new(initial: string) -> FSM
- FSM:addState(name: string, def?: { onEnter?: (prev?, data?) -> (), onExit?: (next?, data?) -> () })
- FSM:can(target: string) -> boolean; FSM:transition(target: string, data?: any)
- FSM:destroy()

### CooldownUtil — per-key cooldowns
- new(defaultDuration: number) -> CD
- CD:set(key: string, duration?: number)
- CD:timeRemaining(key: string) -> number
- CD:canUse(key: string) -> boolean; CD:use(key: string) -> boolean; CD:clear(key: string)

### CacheUtil — TTL cache
- new(defaultTtlSeconds?: number, maxSize?: number) -> Cache
- Cache:set(key: string, value: any, ttlSeconds?: number)
- Cache:get(key: string) -> any
- Cache:getOrCompute(key: string, producer: () -> any, ttlSeconds?: number) -> any
- Cache:delete(key: string); Cache:clear(); Cache:size() -> number

### UUIDUtil — ids/strings
- guid() -> string; randomString(length?: number, charset?: string) -> string; shortId(length?: number) -> string

### Observable — reactive value
- new(initial: any) -> Observable
- Observable:get() -> any; Observable:set(v: any)
- Observable.Changed (Signal); Observable:Destroy()

### GeometryUtil — geometry helpers
- aabbFromPoints(points: {Vector3}) -> (Vector3 min, Vector3 max)
- aabbToCFrameSize(minV: Vector3, maxV: Vector3) -> (CFrame, Vector3 size)
- aabbFromInstance(inst: Instance) -> (Vector3 min, Vector3 max)
- rayPlaneIntersection(rayOrigin: Vector3, rayDir: Vector3, planePoint: Vector3, planeNormal: Vector3) -> Vector3?
- closestPointOnSegment(a: Vector3, b: Vector3, p: Vector3) -> Vector3
- pointInTriangle2D(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> boolean

### EasingUtil — easing curves
- linear(t)
- quad/cubic/quart/quint In|Out|InOut(t)
- sine In|Out|InOut(t); expo/circ/back/bounce/elastic variants

### DeepTableUtil — deep ops
- deepClone(t) -> any; deepMerge(dest, src) -> any
- getIn(t, path: {any}, default: any?) -> any; setIn(t, path: {any}, value: any) -> any
- equalsDeep(a, b) -> boolean

### StatUtil — stats helpers
- ema(prev: number?, x: number, alpha: number) -> number
- Running() -> { push: (number)->(), mean: ()->number, min: number, max: number, count: number }

### HashUtil — hashes
- stringHash(s: string) -> number; stableHash(value: any) -> number

### LRUCache — LRU map with TTL
- new(capacity: number) -> LRU
- LRU:set(key: any, value: any, ttlSeconds?: number)
- LRU:get(key: any) -> any
- LRU:delete(key: any); LRU:clear(); LRU:len() -> number

### Memoize — memoize wrapper
- wrap(fn: (...any)->any, options: { capacity?: number, ttl?: number }) -> (memoizedFn: (...any)->any, cache: LRUCache)

### EventBus — pub/sub
- new() -> Bus
- Bus:subscribe(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:publish(topic: string, ...: any)
- Bus:once(topic: string, handler: (...any)->()) -> RBXScriptConnection
- Bus:hasSubscribers(topic: string) -> boolean
- Bus:Destroy()

### Deque — double-ended queue
- new() -> Deque
- Deque:pushLeft(v); Deque:pushRight(v); Deque:popLeft() -> any; Deque:popRight() -> any
- Deque:peekLeft() -> any; Deque:peekRight() -> any; Deque:clear(); Deque:len() -> number

### PriorityQueue — min-heap
- new(lessFn?: (a:any,b:any)->boolean) -> PQ
- PQ:push(v); PQ:pop() -> any; PQ:peek() -> any; PQ:len() -> number

---

## Client modules

All available from the Client bundle (`Client.X`).

### CameraUtil — camera helpers
- setSubject(subject?: Instance)
- tweenTo(cf: CFrame, info: TweenInfo, focus?: Vector3)
- shake(duration: number, magnitude?: number, frequency?: number)

### NotificationUtil — quick toasts
- show(text: string, opts: { duration?: number, stroke?: boolean, position?: UDim2, anchor?: Vector2 })

### NotificationQueue — queued/stacked toasts
- new(opts?: { maxVisible?: number, gap?: number, position?: UDim2, anchor?: Vector2 }) -> Queue
- Queue:destroy(); Queue:setMaxVisible(n: number); Queue:setGap(px: number)
- Queue:setPosition(pos: UDim2, anchor?: Vector2); Queue:clear()
- Queue:show(text: string, opts?); Queue:enqueue(text: string, opts?)

### ModalUtil — confirm dialogs
- confirm(opts: { title?: string, message?: string, buttons?: {string} }) -> Promise<string>

### ClientRateLimiter — client-side limiter
- new(capacity: number, refillPerSecond: number) -> Limiter
- Limiter:allow(key: string, tokens?: number) -> (boolean, number)

### ProgressBar — simple progress UI
- create(parent?: Instance, opts?: { size?: UDim2, position?: UDim2, corner?: number, theme?: {bg:Color3, fill:Color3, text:Color3} }) -> Bar
- Bar:SetProgress(alpha: number, tweenSeconds?: number)
- Bar:SetText(text?: string); Bar:Show(); Bar:Hide(); Bar:Destroy()

### InputUtil — input helpers
- bindAction(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- bindOnce(name: string, callback: ()->(), touchEnabled?: boolean, keys?: {Enum.KeyCode|Enum.UserInputType}) -> ()->()
- onKey(keyCode: Enum.KeyCode, fn: (pressed:boolean)->()) -> RBXScriptConnection
- isTouch() -> boolean; isGamepad() -> boolean; isKeyboardMouse() -> boolean

### DeviceUtil — device info
- viewport() -> Vector2; platform() -> string; isSmallScreen() -> boolean; safeAreaInset() -> Vector2

### ScreenFadeUtil — fade overlay
- fadeIn(duration: number, color?: Color3, transparency?: number)
- fadeOut(duration: number)
- flash(duration: number)

### GuiDragUtil — draggable frames
- attach(frame: GuiObject, opts?: { clampToScreen?: boolean, sensitivity?: number }) -> ()->()

### ViewportUtil — ViewportFrame helpers
- createViewport(size: UDim2, bg?: Color3) -> ViewportFrame
- setModel(vpf: ViewportFrame, model: Model, opts?: { cameraCFrame?: CFrame, distance?: number })

### CursorUtil — mouse cursor
- show(); hide(); setIcon(icon: string)
- lockCenter(enable: boolean); isLocked() -> boolean

### ScreenShakeUtil — camera shake
- start(params: { amplitude: number, frequency: number, duration: number, decay?: boolean }) -> ()->()

### HighlightUtil — highlight parts/models
- show(target: Instance, options?: { color?: Color3, fill?: number, outline?: number, duration?: number }) -> (Highlight, ()->())

### TooltipUtil — hover tooltips
- bind(guiObject: GuiObject, options: { text: string, delay?: number, offset?: Vector2 }) -> ()->()

### HapticUtil — gamepad rumble
- rumble(gamepad: Enum.UserInputType, intensity: number, duration: number)
- rumbleAll(intensity: number, duration: number)

### ScreenResizeUtil — viewport size changes
- onResize(handler: (Vector2)->()) -> RBXScriptConnection
- getViewportSize() -> Vector2

### CursorRayUtil — screen-to-world/raycast
- screenPointToRay(point: Vector2, depth?: number) -> (Vector3 origin, Vector3 direction)
- mouseRay(depth?: number) -> (Vector3 origin, Vector3 direction)
- raycastFromScreenPoint(point: Vector2, params?: RaycastParams) -> RaycastResult?
- raycastMouse(params?: RaycastParams) -> RaycastResult?
- worldPointFromScreen(point: Vector2, depth: number) -> Vector3
- worldPointFromMouse(depth: number) -> Vector3

### ButtonFXUtil — hover/press scale FX
- bind(button: GuiObject, options?: { hoverScale?: number, pressScale?: number, tween?: TweenInfo }) -> ()->()

### LayoutUtil — UI layout builders
- createList(options?: { parent?: Instance, padding?: UDim, fill?: boolean, align?: Enum.HorizontalAlignment }) -> UIListLayout
- createGrid(options?: { parent?: Instance, cellSize?: UDim2, cellPadding?: UDim2 }) -> UIGridLayout
- createTable(options?: { parent?: Instance, padding?: UDim }) -> UITableLayout
- createPadding(options?: { parent?: Instance, left?: UDim, right?: UDim, top?: UDim, bottom?: UDim }) -> UIPadding

### KeybindHintUtil — keybind hints
- show(options: { key: string, text: string, position?: UDim2 }) -> string|number
- remove(id: string|number)

### TouchGestureUtil — pan/pinch/rotate
- bind(options?: { minPinch?: number, minRotate?: number }) -> Controller
- Controller.OnPan(delta: Vector2); Controller.OnPinch(delta: number); Controller.OnRotate(radians: number)
- Controller:Destroy()

### OffscreenIndicatorUtil — edge arrows
- attach(target: Instance, options?: { margin?: number, color?: Color3 }) -> ()->()

### ScrollUtil — smooth scroll
- smoothScrollTo(scroller: ScrollingFrame, target: Vector2, tweenInfo?: TweenInfo)
- scrollBy(scroller: ScrollingFrame, dx: number, dy: number, tweenInfo?: TweenInfo)

### SliderUtil — horizontal slider
- create(options: { parent?: Instance, width?: number, initial?: number }) -> Slider
- Slider.OnChanged(value: number) (Signal); Slider:SetValue(value: number)

---

## Server modules

All available from the Server bundle (`Server.X`).

### TeleportUtil — teleports
- teleportInServer(target: Player|Model, destination: CFrame|Vector3|BasePart, options?: { keepOrientation?: boolean, offset?: Vector3, unseat?: boolean }) -> boolean
- teleportToPlace(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- teleportToPlaceInstance(placeId: number, jobId: string, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean, string?)
- reserveServer(placeId: number) -> (string accessCode, string reservedServerId)
- teleportToPrivateServer(placeId: number, players: Player|{Player}, teleportData?: any, options?: { retries?: number, backoff?: number }) -> (boolean ok, string? errMsg, string? accessCode)

### MatchmakingUtil — queue/party matching
- new(placeId: number, partySize: number, opts?: { retries?: number, backoff?: number, pollSeconds?: number }) -> MM
- MM:onMatched(cb: ({Player})->()) -> RBXScriptConnection
- MM:enqueue(player: Player); MM:dequeue(player: Player); MM:size() -> number; MM:flush(); MM:destroy()

### HttpUtil — HTTP requests
- request(opts: { method: string, url: string, headers?: table, body?: string|table, json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res: { StatusCode: number, Success: boolean, Headers: table, Body: string, Json?: any }?, err?: string)
- get(url: string, headers?: table, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- post(url: string, body: any, headers?: table, opts?: { json?: boolean, retries?: number, backoff?: number }) -> (ok: boolean, res?: table, err?: string)
- fetchJson(url: string, opts?: { retries?: number, backoff?: number }) -> (ok: boolean, json?: any, err?: string)
- encode(value: any) -> string; decode(str: string) -> any

### DataStoreUtil — DataStore helpers
- getStore(name: string, scope?: string) -> DataStore
- waitForBudget(type: Enum.DataStoreRequestType, min?: number, timeout?: number) -> boolean
- get(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, value?: any, err?: string)
- set(store: GlobalDataStore, key: string, value: any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)
- update(store: GlobalDataStore, key: string, fn: (old:any)->any, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: any, err?: string)
- increment(store: GlobalDataStore, key: string, delta: number, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, newValue?: number, err?: string)
- remove(store: GlobalDataStore, key: string, opts?: { retries?: number, backoff?: number, budget?: boolean }) -> (ok: boolean, err?: string)

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

### MessagingServiceUtil — pub/sub
- publish(topic: string, data: any, opts?: { retries?: number, backoff?: number }) -> (boolean, any)
- subscribe(topic: string, handler: (data:any, message:any)->(), opts?: { safe?: boolean }) -> { Disconnect: ()->() }

### MemoryStoreUtil — queues/maps
- queue(name: string) -> Queue
	- Queue.enqueue(item: any, ttl?: number) -> (boolean, any)
	- Queue.tryDequeue(count?: number, waitTimeout?: number) -> (boolean, { entries: { { Id: string, Value: any } } }|string)
	- Queue.complete(entry: { Id: string, Value: any }) -> (boolean, any)
- map(name: string) -> Map
	- Map.get(key: string) -> (boolean, any)
	- Map.set(key: string, value: any, expiration?: number) -> (boolean, any)
	- Map.increment(key: string, delta?: number, expiration?: number) -> (boolean, number|any)

### BadgeUtil — badges
- hasBadge(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, boolean|any)
- awardIfNotOwned(userIdOrPlayer: number|Player, badgeId: number) -> (boolean, any)

### GroupUtil — group info
- getRoleInGroup(userIdOrPlayer: number|Player, groupId: number) -> (string?|nil, string?|nil)
- getRankInGroup(userIdOrPlayer: number|Player, groupId: number) -> (number, string?|nil)
- isInGroup(userIdOrPlayer: number|Player, groupId: number, minRank?: number) -> boolean

### MarketplaceUtil — purchases
- ownsGamePass(player: Player, gamePassId: number) -> (boolean, boolean|any)
- promptGamePass(player: Player, gamePassId: number)
- promptProduct(player: Player, productId: number)
- createReceiptRouter(map: { [productId: number]: (player: Player, receiptInfo: any) -> Enum.ProductPurchaseDecision }) -> (receiptInfo: any) -> Enum.ProductPurchaseDecision
- bindProcessReceipt(fn: (receiptInfo: any) -> Enum.ProductPurchaseDecision)

### PolicyUtil — policy checks
- getPolicy(player: Player) -> (table?|nil, string?|nil)
- arePaidRandomItemsRestricted(player: Player) -> boolean?|nil
- isSubjectToChinaPolicies(player: Player) -> boolean?|nil
- isVoiceEnabled(player: Player) -> boolean?|nil

### BanUtil — bans
- ban(userIdOrPlayer: number|Player, reason?: string, durationSeconds?: number, by?: string) -> (boolean, any)
- unban(userIdOrPlayer: number|Player) -> (boolean, any)
- getBan(userIdOrPlayer: number|Player) -> ({ reason?: string, expiresAt?: number, by?: string }?|nil, any)
- isBanned(userIdOrPlayer: number|Player) -> boolean
- shouldKick(player: Player) -> (boolean, string?)

### WebhookUtil — JSON webhooks
- postJson(url: string, payload: table, opts?: { headers?: table, compress?: boolean, httpService?: HttpService }) -> (boolean, any)

### ChatFilterUtil — text filter
- filterForBroadcast(text: string, fromUserId: number) -> (boolean, string|any)
- filterForUser(text: string, fromUserId: number, toUserId: number) -> (boolean, string|any)

### AccessControlUtil — feature gates
- canUseFeature(player: Player, rules: { allowUserIds?: {number}, denyUserIds?: {number}, group?: { id: number, minRank?: number }, gamePassId?: number, requireVoice?: boolean, forbidPaidRandomItems?: boolean }, deps?: { PolicyUtil?: any, GroupUtil?: any, MarketplaceUtil?: any }) -> (boolean, string?)

### JobScheduler — background jobs
- new(name: string, opts?: { visibility?: number, poll?: number }) -> Scheduler
- Scheduler:enqueue(payload: any, ttl?: number) -> (boolean, any)
- Scheduler:startWorker(handler: (payload: any, entry: { Id: string, Value: any })->())
- Scheduler:stopWorker()

### AuditLogUtil — batched logging
- new(url: string, opts?: { batchSize?: number, flushInterval?: number }) -> Logger
- Logger:setDestination(url: string)
- Logger:log(eventName: string, fields?: table)
- Logger:start(); Logger:stop()

### CharacterScaleUtil — R15 scaling
- getScales(target: Player|Model|Humanoid) -> { height: number, width: number, depth: number, head: number }
- setScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, options?: { clamp?: boolean }) -> (boolean, string?)
- setUniformScale(target: Player|Model|Humanoid, scale: number, options?: { clamp?: boolean }) -> (boolean, string?)
- tweenScale(target: Player|Model|Humanoid, scales: { height?: number, width?: number, depth?: number, head?: number }, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- tweenUniformScale(target: Player|Model|Humanoid, scale: number, tweenInfo: TweenInfo, options?: { yield?: boolean }) -> (boolean, string?)
- reset(target: Player|Model|Humanoid) -> (boolean, string?)

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

### CharacterAppearanceUtil — outfits/colors/accessories
- applyDescription(target: Player|Model|Humanoid, description: HumanoidDescription) -> (boolean, string?)
- applyUserOutfit(target: Player|Model|Humanoid, userId: number) -> (boolean, string?)
- applyOutfitId(target: Player|Model|Humanoid, outfitId: number) -> (boolean, string?)
- setBodyColors(targetOrCharacter: Player|Model|Humanoid, colors?: { Head?: BrickColor|Color3|string, LeftArm?: BrickColor|Color3|string, RightArm?: BrickColor|Color3|string, LeftLeg?: BrickColor|Color3|string, RightLeg?: BrickColor|Color3|string, Torso?: BrickColor|Color3|string }) -> BodyColors|nil, string?
- addAccessory(target: Player|Model|Humanoid, accessory: Accessory) -> (boolean, string?)
- removeAccessories(target: Player|Model|Humanoid, predicate?: (Accessory)->boolean) -> (number|false, string?)
- setClothingIds(target: Player|Model|Humanoid, shirtId?: number|string, pantsId?: number|string) -> (boolean, string?)

### CharacterVisibilityUtil — transparency/ghost
- setTransparency(target: Player|Model|Humanoid, alpha: number, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setInvisible(target: Player|Model|Humanoid, enabled: boolean, options?: { nonCollide?: boolean }) -> (boolean, string?)
- setGhostMode(target: Player|Model|Humanoid, enabled: boolean) -> (boolean, string?)

### CharacterHealthUtil — health/invulnerability
- setMaxHealth(target: Player|Model|Humanoid, maxHealth: number, options?: { clamp?: boolean }) -> (boolean, string?)
- heal(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- damage(target: Player|Model|Humanoid, amount: number) -> (boolean, string?)
- setInvulnerable(target: Player|Model|Humanoid, enabled: boolean, options?: { duration?: number }) -> (boolean, (() -> ())?)

---

## Usage notes
- Prefer bundle requires; they export all modules as fields.
- Server-only modules must be required on the server.
- For practical examples, see `Tests/AllModules.client.lua` and `Tests/AllModules.server.lua`.
