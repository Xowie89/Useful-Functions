-- RandomUtil.lua
-- RNG helpers with a simple RNG object wrapper around Random.new
-- API:
--   RandomUtil.new(seed?) -> RNG
--   RNG:integer(min, max), RNG:number(min, max), RNG:choice(list), RNG:shuffle(list, inPlace?)
--   RNG:sample(list, k, unique?) -> {items}, RNG:weighted(entries) -> item
--   RNG:bag(items) -> { draw:() -> any?, remaining:() -> number, reset:() }
--   Also provides module-level defaults: RandomUtil.default (seeded at runtime)

local RandomUtil = {}
RandomUtil.__index = RandomUtil

export type RNG = {
	integer: (self: RNG, min: number, max: number) -> number,
	number: (self: RNG, min: number, max: number) -> number,
	choice: (self: RNG, list: {any}) -> any?,
	shuffle: (self: RNG, list: {any}, inPlace: boolean?) -> {any},
	sample: (self: RNG, list: {any}, k: number, unique: boolean?) -> {any},
	weighted: (self: RNG, entries: { {item: any, weight: number} }) -> any?,
	bag: (self: RNG, items: {any}) -> { draw: () -> any?, remaining: () -> number, reset: () -> () },
}

local function newRandom(seed: number?)
	if seed ~= nil then return Random.new(seed) end
	return Random.new()
end

function RandomUtil.new(seed: number?): RNG
	local self = setmetatable({}, RandomUtil)
	self._rng = newRandom(seed)
	return self :: any
end

function RandomUtil:integer(min: number, max: number): number
	return self._rng:NextInteger(min, max)
end

function RandomUtil:number(min: number, max: number): number
	return self._rng:NextNumber(min, max)
end

function RandomUtil:choice(list: {any}): any?
	local n = #list
	if n == 0 then return nil end
	return list[self:integer(1, n)]
end

function RandomUtil:shuffle(list: {any}, inPlace: boolean?): {any}
	local arr = list
	if not inPlace then
		arr = table.clone(list)
	end
	for i = #arr, 2, -1 do
		local j = self:integer(1, i)
		arr[i], arr[j] = arr[j], arr[i]
	end
	return arr
end

function RandomUtil:sample(list: {any}, k: number, unique: boolean?): {any}
	k = math.max(0, math.floor(k))
	if k == 0 then return {} end
	if unique ~= false then
		local arr = self:shuffle(list, false)
		local out = {}
		for i = 1, math.min(k, #arr) do out[i] = arr[i] end
		return out
	else
		local out = {}
		for i = 1, k do out[i] = self:choice(list) end
		return out
	end
end

function RandomUtil:weighted(entries: { {item: any, weight: number} })
	local total = 0
	for _, e in ipairs(entries) do total += math.max(0, e.weight or 0) end
	if total <= 0 then return nil end
	local r = self:number(0, total)
	local acc = 0
	for _, e in ipairs(entries) do
		acc += math.max(0, e.weight or 0)
		if r <= acc then return e.item end
	end
	return entries[#entries] and entries[#entries].item or nil
end

function RandomUtil:bag(items: {any})
	local pool = table.clone(items)
	local idx = 1
	local order = self:shuffle(pool, false)
	return {
		draw = function()
			if idx > #order then return nil end
			local item = order[idx]
			idx += 1
			return item
		end,
		remaining = function() return #order - (idx - 1) end,
		reset = function()
			idx = 1
			order = self:shuffle(pool, false)
		end,
	}
end

RandomUtil.default = RandomUtil.new()

return RandomUtil