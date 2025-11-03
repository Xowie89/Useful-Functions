-- PromiseUtil.lua
-- Lightweight Promise implementation for Roblox Luau + helpers
-- Features:
--   Promise.new(executor), :andThen, :catch, :finally
--   Promise.resolve, Promise.reject, Promise.delay(seconds, value)
--   Promise.all(arrayOfPromises), Promise.race(arrayOfPromises)
--   Promise.timeout(promiseOrFn, seconds, timeoutErr?), Promise.retry(fn, attempts?, backoffSeconds?)

local Promise = {}
Promise.__index = Promise

export type Executor = (resolve: (any) -> (), reject: (any) -> ()) -> ()
export type OnFulfilled = (any) -> any
export type OnRejected = (any) -> any

local STATE_PENDING = 0
local STATE_FULFILLED = 1
local STATE_REJECTED = 2

function Promise.new(executor: Executor)
	local self = setmetatable({}, Promise)
	self._state = STATE_PENDING
	self._value = nil
	self._handlers = {} -- { { onFulfilled, onRejected, resolve, reject } }
	local function resolve(value)
		if self._state ~= STATE_PENDING then return end
		if getmetatable(value) == Promise then
			-- adopt state
			value:andThen(function(v)
				resolve(v)
			end, function(err)
				reject(err)
			end)
			return
		end
		self._state = STATE_FULFILLED
		self._value = value
		for _, h in ipairs(self._handlers) do
			task.defer(function()
				if h.onFulfilled then
					local ok, res = pcall(h.onFulfilled, value)
					if ok then h.resolve(res) else h.reject(res) end
				else
					h.resolve(value)
				end
			end)
		end
		self._handlers = {}
	end
	local function reject(reason)
		if self._state ~= STATE_PENDING then return end
		self._state = STATE_REJECTED
		self._value = reason
		for _, h in ipairs(self._handlers) do
			task.defer(function()
				if h.onRejected then
					local ok, res = pcall(h.onRejected, reason)
					if ok then h.resolve(res) else h.reject(res) end
				else
					h.reject(reason)
				end
			end)
		end
		self._handlers = {}
	end
	local ok, err = pcall(function()
		executor(resolve, reject)
	end)
	if not ok then
		reject(err)
	end
	return self
end

function Promise:isSettled()
	return self._state ~= STATE_PENDING
end

function Promise:andThen(onFulfilled: OnFulfilled?, onRejected: OnRejected?)
	return Promise.new(function(resolve, reject)
		local handler = { onFulfilled = onFulfilled, onRejected = onRejected, resolve = resolve, reject = reject }
		if self._state == STATE_PENDING then
			table.insert(self._handlers, handler)
		elseif self._state == STATE_FULFILLED then
			task.defer(function()
				if onFulfilled then
					local ok, res = pcall(onFulfilled, self._value)
					if ok then resolve(res) else reject(res) end
				else
					resolve(self._value)
				end
			end)
		else -- REJECTED
			task.defer(function()
				if onRejected then
					local ok, res = pcall(onRejected, self._value)
					if ok then resolve(res) else reject(res) end
				else
					reject(self._value)
				end
			end)
		end
	end)
end

function Promise:catch(onRejected: OnRejected)
	return self:andThen(nil, onRejected)
end

function Promise:finally(onFinally: () -> ())
	return self:andThen(function(v)
		onFinally()
		return v
	end, function(err)
		onFinally()
		return Promise.reject(err)
	end)
end

function Promise.resolve(value: any)
	return Promise.new(function(resolve)
		resolve(value)
	end)
end

function Promise.reject(reason: any)
	return Promise.new(function(_, reject)
		reject(reason)
	end)
end

function Promise.delay(seconds: number, value: any?)
	return Promise.new(function(resolve)
		task.delay(seconds, function()
			resolve(value)
		end)
	end)
end

function Promise.all(list: {any})
	return Promise.new(function(resolve, reject)
		local results = table.create(#list)
		local remaining = #list
		if remaining == 0 then resolve({}) return end
		for i, p in ipairs(list) do
			local function fulfill(v)
				results[i] = v
				remaining -= 1
				if remaining == 0 then resolve(results) end
			end
			if getmetatable(p) == Promise then
				p:andThen(fulfill, reject)
			else
				fulfill(p)
			end
		end
	end)
end

function Promise.race(list: {any})
	return Promise.new(function(resolve, reject)
		for _, p in ipairs(list) do
			if getmetatable(p) == Promise then
				p:andThen(resolve, reject)
			else
				resolve(p)
				break
			end
		end
	end)
end

function Promise.timeout(pOrFn: any, seconds: number, timeoutErr: any?)
	local p = (getmetatable(pOrFn) == Promise) and pOrFn or Promise.new(function(resolve, reject)
		local ok, res = pcall(pOrFn)
		if ok then resolve(res) else reject(res) end
	end)
	return Promise.race({
		p,
		Promise.delay(seconds):andThen(function()
			return Promise.reject(timeoutErr or "Timeout")
		end),
	})
end

function Promise.retry(fn: () -> any, attempts: number?, backoff: number?)
	attempts = attempts or 3
	backoff = backoff or 1
	return Promise.new(function(resolve, reject)
		local attempt = 0
		local function step()
			attempt += 1
			local ok, res = pcall(fn)
			if ok then
				resolve(res)
			else
				if attempt >= attempts then
					reject(res)
				else
					task.delay(backoff * attempt, step)
				end
			end
		end
		step()
	end)
end

return Promise