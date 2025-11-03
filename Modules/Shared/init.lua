-- Modules/Shared/init.lua
-- Aggregates shared utilities safe for ReplicatedStorage (no server-only)

local Modules = script.Parent

return {
    Signal = require(Modules.Signal),
    Maid = require(Modules.Maid),
    Debounce = require(Modules.Debounce),
    Timer = require(Modules.Timer),
    TweenUtil = require(Modules.TweenUtil),
    InstanceUtil = require(Modules.InstanceUtil),
    TableUtil = require(Modules.TableUtil),
    StringUtil = require(Modules.StringUtil),
    MathUtil = require(Modules.MathUtil),
    RaycastUtil = require(Modules.RaycastUtil),
    ColorUtil = require(Modules.ColorUtil),
    CollectionUtil = require(Modules.CollectionUtil),
    TimeUtil = require(Modules.TimeUtil),
    PatternUtil = require(Modules.PatternUtil),
    PromiseUtil = require(Modules.PromiseUtil),
    PlayerUtil = require(Modules.PlayerUtil),
    SoundUtil = require(Modules.SoundUtil),
    CFrameUtil = require(Modules.CFrameUtil),
    RandomUtil = require(Modules.RandomUtil),
    RateLimiter = require(Modules.RateLimiter),
    CooldownUtil = require(Modules.CooldownUtil),
    StateMachine = require(Modules.StateMachine),
}
