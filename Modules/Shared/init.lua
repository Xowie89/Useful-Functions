-- Modules/Shared/init.lua
-- Aggregates shared utilities safe for ReplicatedStorage (no server-only)

-- Resolve from the Shared folder itself
local Shared = script.Parent

return {
    Signal = require(Shared.Signal),
    Maid = require(Shared.Maid),
    Debounce = require(Shared.Debounce),
    Timer = require(Shared.Timer),
    TweenUtil = require(Shared.TweenUtil),
    InstanceUtil = require(Shared.InstanceUtil),
    TableUtil = require(Shared.TableUtil),
    StringUtil = require(Shared.StringUtil),
    MathUtil = require(Shared.MathUtil),
    RaycastUtil = require(Shared.RaycastUtil),
    ColorUtil = require(Shared.ColorUtil),
    CollectionUtil = require(Shared.CollectionUtil),
    TimeUtil = require(Shared.TimeUtil),
    PatternUtil = require(Shared.PatternUtil),
    PromiseUtil = require(Shared.PromiseUtil),
    PlayerUtil = require(Shared.PlayerUtil),
    SoundUtil = require(Shared.SoundUtil),
    CFrameUtil = require(Shared.CFrameUtil),
    RandomUtil = require(Shared.RandomUtil),
    RateLimiter = require(Shared.RateLimiter),
    CooldownUtil = require(Shared.CooldownUtil),
    StateMachine = require(Shared.StateMachine),
    -- New shared modules
    VectorUtil = require(Shared.VectorUtil),
    FormatUtil = require(Shared.FormatUtil),
    UUIDUtil = require(Shared.UUIDUtil),
    CacheUtil = require(Shared.CacheUtil),
    Observable = require(Shared.Observable),
    -- Batch 2 shared modules
    GeometryUtil = require(Shared.GeometryUtil),
    EasingUtil = require(Shared.EasingUtil),
    DeepTableUtil = require(Shared.DeepTableUtil),
    StatUtil = require(Shared.StatUtil),
    HashUtil = require(Shared.HashUtil),
    -- Data helpers
    LRUCache = require(Shared.LRUCache),
    Memoize = require(Shared.Memoize),
    EventBus = require(Shared.EventBus),
    Deque = require(Shared.Deque),
    PriorityQueue = require(Shared.PriorityQueue),
}
