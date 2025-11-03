-- init.lua
-- Aggregates utilities for easy requiring

-- IMPORTANT: This ModuleScript lives inside the `Modules` folder.
-- Use script.Parent to reference sibling modules in the folder.
local Modules = script.Parent

return {
	Signal = require(Modules.Signal),
	Maid = require(Modules.Maid),
	Debounce = require(Modules.Debounce),
	Timer = require(Modules.Timer),
	TweenUtil = require(Modules.TweenUtil),
	TeleportUtil = require(Modules.TeleportUtil),
	InstanceUtil = require(Modules.InstanceUtil),
	TableUtil = require(Modules.TableUtil),
	StringUtil = require(Modules.StringUtil),
	MathUtil = require(Modules.MathUtil),
	RaycastUtil = require(Modules.RaycastUtil),
	ColorUtil = require(Modules.ColorUtil),
	HttpUtil = require(Modules.HttpUtil),
	DataStoreUtil = require(Modules.DataStoreUtil),
	CollectionUtil = require(Modules.CollectionUtil),
	TimeUtil = require(Modules.TimeUtil),
	PatternUtil = require(Modules.PatternUtil),
	PromiseUtil = require(Modules.PromiseUtil),
	PlayerUtil = require(Modules.PlayerUtil),
	LeaderstatsUtil = require(Modules.LeaderstatsUtil),
}