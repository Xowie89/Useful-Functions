-- CollectionUtil.lua
-- CollectionService helpers for tagging and change listeners
-- API:
--   addTag(instance, tag), removeTag(instance, tag), hasTag(instance, tag)
--   getTagged(tag) -> {Instance}
--   onAdded(tag, callback) -> RBXScriptConnection
--   onRemoved(tag, callback) -> RBXScriptConnection
--   watchTag(tag, onAdded, onRemoved?) -> { disconnect: () -> () }

local CollectionService = game:GetService("CollectionService")

local CollectionUtil = {}

function CollectionUtil.addTag(inst: Instance, tag: string)
	CollectionService:AddTag(inst, tag)
end

function CollectionUtil.removeTag(inst: Instance, tag: string)
	CollectionService:RemoveTag(inst, tag)
end

function CollectionUtil.hasTag(inst: Instance, tag: string): boolean
	return CollectionService:HasTag(inst, tag)
end

function CollectionUtil.getTagged(tag: string): {Instance}
	return CollectionService:GetTagged(tag)
end

function CollectionUtil.onAdded(tag: string, callback: (Instance) -> ())
	return CollectionService:GetInstanceAddedSignal(tag):Connect(callback)
end

function CollectionUtil.onRemoved(tag: string, callback: (Instance) -> ())
	return CollectionService:GetInstanceRemovedSignal(tag):Connect(callback)
end

function CollectionUtil.watchTag(tag: string, onAdded: (Instance) -> (), onRemoved: ((Instance) -> ())?)
	local conns = {}
	for _, inst in ipairs(CollectionService:GetTagged(tag)) do
		task.spawn(onAdded, inst)
	end
	conns[1] = CollectionService:GetInstanceAddedSignal(tag):Connect(onAdded)
	if onRemoved then
		conns[2] = CollectionService:GetInstanceRemovedSignal(tag):Connect(onRemoved)
	end
	return {
		disconnect = function()
			for _, c in ipairs(conns) do if c then c:Disconnect() end end
		end
	}
end

return CollectionUtil