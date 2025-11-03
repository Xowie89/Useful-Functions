-- InstanceUtil.lua
-- Helpers for creating, finding, and cleaning up Instances
-- API:
--   InstanceUtil.create(className, props?, children?) -> Instance
--   InstanceUtil.getOrCreate(parent, className, name?) -> Instance
--   InstanceUtil.waitForDescendant(parent, name, timeoutSeconds?) -> Instance?
--   InstanceUtil.destroyChildren(parent, predicate?) -> number
--   InstanceUtil.cloneInto(instance, parent, props?) -> Instance

local InstanceUtil = {}

export type Props = { [string]: any }

-- Create an instance with props and children
function InstanceUtil.create(className: string, props: Props?, children: {Instance}?): Instance
	local inst = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				-- defer setting Parent until after other props for performance
				continue
			end
			(inst :: any)[k] = v
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

-- Get an existing child by name/class or create one
function InstanceUtil.getOrCreate(parent: Instance, className: string, name: string?): Instance
	assert(parent ~= nil, "parent is required")
	name = name or className
	local found = parent:FindFirstChild(name)
	if found and found.ClassName == className then
		return found
	end
	return InstanceUtil.create(className, { Name = name, Parent = parent })
end

-- Wait for a descendant with a specific Name (not Path) until timeout
function InstanceUtil.waitForDescendant(parent: Instance, name: string, timeoutSeconds: number?): Instance?
	local deadline = if timeoutSeconds then (time() + timeoutSeconds) else nil
	local function search()
		for _, d in ipairs(parent:GetDescendants()) do
			if d.Name == name then
				return d
			end
		end
		return nil
	end
	local existing = search()
	if existing then return existing end
	local conn
	local found: Instance? = nil
	conn = parent.DescendantAdded:Connect(function(d)
		if d.Name == name then
			found = d
			if conn then conn:Disconnect() end
		end
	end)
	while not found do
		if deadline and time() > deadline then break end
		task.wait(0.1)
	end
	if conn then conn:Disconnect() end
	return found
end

-- Destroy children that match predicate (or all if predicate omitted)
function InstanceUtil.destroyChildren(parent: Instance, predicate: ((Instance) -> boolean)?)
	local n = 0
	for _, child in ipairs(parent:GetChildren()) do
		if not predicate or predicate(child) then
			pcall(function() child:Destroy() end)
			n += 1
		end
	end
	return n
end

-- Clone an instance into a parent, optionally applying props after cloning
function InstanceUtil.cloneInto(source: Instance, parent: Instance, props: Props?): Instance
	local clone = source:Clone()
	clone.Parent = parent
	if props then
		for k, v in pairs(props) do
			(clone :: any)[k] = v
		end
	end
	return clone
end

return InstanceUtil