-- DataStoreUtil.lua
-- DataStore helpers with retries and request budget waits
-- API (server):
--   DataStoreUtil.getStore(name, scope?) -> DataStore
--   DataStoreUtil.waitForBudget(requestType: Enum.DataStoreRequestType, minBudget?: number, timeoutSeconds?: number) -> boolean
--   DataStoreUtil.get(store, key, opts?) -> ok:boolean, value:any, err?:string
--   DataStoreUtil.set(store, key, value, opts?) -> ok:boolean, err?:string
--   DataStoreUtil.update(store, key, transformFn, opts?) -> ok:boolean, newValue:any, err?:string
--   DataStoreUtil.increment(store, key, delta:number, opts?) -> ok:boolean, newValue:number?, err?:string
--   DataStoreUtil.remove(store, key, opts?) -> ok:boolean, err?:string
-- opts: { retries?: number, backoff?: number, budget?: boolean }

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local DataStoreUtil = {}

local DEFAULT_RETRIES = 3
local DEFAULT_BACKOFF = 1

function DataStoreUtil.getStore(name: string, scope: string?)
	assert(RunService:IsServer(), "DataStoreUtil.getStore must be called on the server")
	return DataStoreService:GetDataStore(name, scope)
end

function DataStoreUtil.waitForBudget(requestType: Enum.DataStoreRequestType, minBudget: number?, timeoutSeconds: number?): boolean
	minBudget = minBudget or 1
	local deadline = if timeoutSeconds then (time() + timeoutSeconds) else nil
	while DataStoreService:GetRequestBudgetForRequestType(requestType) < minBudget do
		if deadline and time() > deadline then return false end
		task.wait(0.2)
	end
	return true
end

local function withRetries(fn, retries: number?, backoff: number?)
	retries = retries or DEFAULT_RETRIES
	backoff = backoff or DEFAULT_BACKOFF
	local attempt = 0
	while true do
		attempt += 1
		local ok, a, b, c = pcall(fn)
		if ok then return true, a, b, c end
		if attempt > retries then
			return false, tostring(a)
		end
		task.wait(backoff * attempt)
	end
end

local function doWithBudget(requestType: Enum.DataStoreRequestType, fn, opts)
	if opts and opts.budget ~= false then
		DataStoreUtil.waitForBudget(requestType, 1, 10)
	end
	return withRetries(fn, opts and opts.retries, opts and opts.backoff)
end

function DataStoreUtil.get(store, key: string, opts)
	local ok, resOrErr = doWithBudget(Enum.DataStoreRequestType.GetAsync, function()
		return store:GetAsync(key)
	end, opts)
	if not ok then return false, nil, resOrErr end
	return true, resOrErr, nil
end

function DataStoreUtil.set(store, key: string, value: any, opts)
	local ok, resOrErr = doWithBudget(Enum.DataStoreRequestType.SetIncrementAsync, function()
		store:SetAsync(key, value)
		return true
	end, opts)
	if not ok then return false, resOrErr end
	return true, nil
end

function DataStoreUtil.update(store, key: string, transformFn: (any) -> any, opts)
	local ok, newValueOrErr = doWithBudget(Enum.DataStoreRequestType.UpdateAsync, function()
		return store:UpdateAsync(key, function(old)
			local newVal = transformFn(old)
			return newVal
		end)
	end, opts)
	if not ok then return false, nil, newValueOrErr end
	return true, newValueOrErr, nil
end

function DataStoreUtil.increment(store, key: string, delta: number, opts)
	local ok, newValueOrErr = doWithBudget(Enum.DataStoreRequestType.SetIncrementAsync, function()
		return store:IncrementAsync(key, delta)
	end, opts)
	if not ok then return false, nil, newValueOrErr end
	return true, newValueOrErr, nil
end

function DataStoreUtil.remove(store, key: string, opts)
	local ok, resOrErr = doWithBudget(Enum.DataStoreRequestType.UpdateAsync, function()
		store:RemoveAsync(key)
		return true
	end, opts)
	if not ok then return false, resOrErr end
	return true, nil
end

return DataStoreUtil