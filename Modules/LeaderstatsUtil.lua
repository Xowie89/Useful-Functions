-- LeaderstatsUtil.lua
-- Helpers to set up leaderstats and manage stats/currency
-- API (server):
--   ensureFolder(player) -> Folder
--   addNumber(player, name, initial?) -> NumberValue
--   addInt(player, name, initial?) -> IntValue
--   addString(player, name, initial?) -> StringValue
--   get(player, name) -> ValueBase?
--   getNumber(player, name) -> number?
--   set(player, name, value)
--   increment(player, name, delta) -> number
--   bindAutoSetup(Players) -> disconnectFn   -- optional helper to create leaderstats on PlayerAdded
--   attachPersistence(store, keyFn) -> { load(player), save(player) }  -- optional DataStore hooks

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LeaderstatsUtil = {}

local function ensureFolder(player: Player): Folder
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player
	end
	return ls
end
LeaderstatsUtil.ensureFolder = ensureFolder

local function addValue(player: Player, className: string, name: string, initial)
	local ls = ensureFolder(player)
	local v = ls:FindFirstChild(name)
	if not v or v.ClassName ~= className then
		if v then v:Destroy() end
		v = Instance.new(className)
		v.Name = name
		v.Parent = ls
	end
	if initial ~= nil then
		(v :: any).Value = initial
	end
	return v
end

function LeaderstatsUtil.addNumber(player: Player, name: string, initial: number?)
	return addValue(player, "NumberValue", name, initial or 0)
end

function LeaderstatsUtil.addInt(player: Player, name: string, initial: number?)
	return addValue(player, "IntValue", name, initial or 0)
end

function LeaderstatsUtil.addString(player: Player, name: string, initial: string?)
	return addValue(player, "StringValue", name, initial or "")
end

function LeaderstatsUtil.get(player: Player, name: string): ValueBase?
	local ls = player:FindFirstChild("leaderstats")
	return ls and ls:FindFirstChild(name) or nil
end

function LeaderstatsUtil.getNumber(player: Player, name: string): number?
	local v = LeaderstatsUtil.get(player, name)
	if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then
		return (v :: any).Value
	end
	return nil
end

function LeaderstatsUtil.set(player: Player, name: string, value: any)
	local v = LeaderstatsUtil.get(player, name)
	if not v then
		if type(value) == "number" then
			v = LeaderstatsUtil.addNumber(player, name, value)
		elseif type(value) == "string" then
			v = LeaderstatsUtil.addString(player, name, value)
		else
			v = LeaderstatsUtil.addInt(player, name, tonumber(value) or 0)
		end
	else
		(v :: any).Value = value
	end
	return v
end

function LeaderstatsUtil.increment(player: Player, name: string, delta: number)
	delta = delta or 1
	local current = LeaderstatsUtil.getNumber(player, name) or 0
	local newVal = current + delta
	LeaderstatsUtil.set(player, name, newVal)
	return newVal
end

function LeaderstatsUtil.bindAutoSetup(playersService: Players)
	assert(RunService:IsServer(), "bindAutoSetup must be called on the server")
	local conns = {}
	conns[1] = playersService.PlayerAdded:Connect(function(player)
		ensureFolder(player)
	end)
	for _, p in ipairs(playersService:GetPlayers()) do
		ensureFolder(p)
	end
	return function()
		for _, c in ipairs(conns) do if c then c:Disconnect() end end
	end
end

-- Optional persistence helpers (requires DataStoreUtil module in this repo)
function LeaderstatsUtil.attachPersistence(store, keyFn)
	assert(RunService:IsServer(), "attachPersistence must be called on the server")
	assert(type(keyFn) == "function", "keyFn(player) must return a key string")
	local DataStoreUtil = require(script.Parent.DataStoreUtil)
	local function load(player: Player)
		local key = keyFn(player)
		local ok, data, err = DataStoreUtil.get(store, key)
		if not ok then return false, err end
		if type(data) == "table" then
			for name, value in pairs(data) do
				LeaderstatsUtil.set(player, name, value)
			end
		end
		return true
	end
	local function snapshot(player: Player)
		local ls = player:FindFirstChild("leaderstats")
		local out = {}
		if ls then
			for _, v in ipairs(ls:GetChildren()) do
				local ok, _ = pcall(function()
					out[v.Name] = (v :: any).Value
				end)
			end
		end
		return out
	end
	local function save(player: Player)
		local key = keyFn(player)
		local data = snapshot(player)
		local ok, _, err = DataStoreUtil.update(store, key, function()
			return data
		end)
		return ok, err
	end
	return { load = load, save = save }
end

return LeaderstatsUtil