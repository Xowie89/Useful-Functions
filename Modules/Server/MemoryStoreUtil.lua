-- MemoryStoreUtil.lua
-- Convenience wrappers for MemoryStore Queue and SortedMap with minimal retries

local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
assert(RunService:IsServer(), "MemoryStoreUtil must be used on the server")

local DEFAULT_RETRIES = 3
local DEFAULT_BACKOFF = 1

local function sleep(sec)
	if sec and sec > 0 then task.wait(sec) end
end

local function retry(op, retries, backoff)
	retries = retries or DEFAULT_RETRIES
	backoff = backoff or DEFAULT_BACKOFF
	local lastErr
	for i = 1, math.max(1, retries + 1) do
		local ok, res = pcall(op)
		if ok then return true, res end
		lastErr = res
		if i <= retries then sleep(backoff * (2 ^ (i - 1))) end
	end
	return false, lastErr
end

local M = {}

-- Queue wrapper
function M.queue(name)
	assert(type(name) == "string" and #name > 0, "queue: name is required")
	local q = MemoryStoreService:GetQueue(name)
	local Q = {}

	function Q.enqueue(item, ttl)
		return retry(function()
			q:AddAsync(item, ttl or 60)
			return true
		end)
	end

	-- Returns { entries = {...} } where each entry has .Id and .Value fields (Value == original item)
	function Q.tryDequeue(count, waitTimeout)
		count = math.clamp(count or 1, 1, 100)
		local ok, entriesOrErr = retry(function()
			return true, q:ReadAsync(count, false, waitTimeout or 0)
		end)
		if not ok then return false, entriesOrErr end
		return true, entriesOrErr
	end

	function Q.complete(entry)
		assert(entry and entry.Id, "complete: entry.Id required (use entry from ReadAsync)")
		return retry(function()
			q:RemoveAsync(entry.Id)
			return true
		end)
	end

	return Q
end

-- SortedMap helpers
function M.map(name)
	assert(type(name) == "string" and #name > 0, "map: name is required")
	local sm = MemoryStoreService:GetSortedMap(name)
	local Map = {}

	function Map.get(key)
		local ok, valOrErr = retry(function()
			return true, sm:GetAsync(key)
		end)
		if not ok then return false, valOrErr end
		return true, valOrErr
	end

	function Map.increment(key, delta, expiration)
		delta = delta or 1
		local ok, res = retry(function()
			local val = sm:UpdateAsync(key, function(old)
				old = old or 0
				return (old + delta)
			end, expiration)
			return true, val
		end)
		if not ok then return false, res end
		return true, res
	end

	function Map.set(key, value, expiration)
		return retry(function()
			sm:SetAsync(key, value, expiration)
			return true
		end)
	end

	return Map
end

return M
