-- Debounce.lua
-- Debounce and throttle helpers
-- API:
--   Debounce.debounce(fn, waitSeconds) -> wrappedFn
--   Debounce.throttle(fn, intervalSeconds) -> wrappedFn

local Debounce = {}

-- Debounce: wait for quiet period before running
function Debounce.debounce(fn: (...any) -> (), waitSeconds: number)
	assert(type(fn) == "function", "debounce expects function")
	waitSeconds = waitSeconds or 0.25
	local scheduled = false
	local lastArgs: {any} = {}
	local lastCall
	return function(...)
		lastArgs = table.pack(...)
		lastCall = os.clock()
		if scheduled then return end
		scheduled = true
		task.spawn(function()
			while scheduled do
				local elapsed = os.clock() - lastCall
				if elapsed >= waitSeconds then
					scheduled = false
					fn(table.unpack(lastArgs, 1, lastArgs.n))
					break
				end
				task.wait(math.max(0.03, waitSeconds - elapsed))
			end
		end)
	end
end

-- Throttle: run at most once per interval
function Debounce.throttle(fn: (...any) -> (), intervalSeconds: number)
	assert(type(fn) == "function", "throttle expects function")
	intervalSeconds = intervalSeconds or 0.25
	local lastRun = -math.huge
	local running = false
	return function(...)
		if running then return end
		local now = os.clock()
		if now - lastRun < intervalSeconds then return end
		running = true
		lastRun = now
		task.spawn(function(...)
			local ok, err = pcall(fn, ...)
			if not ok then warn("Throttle fn error:", err) end
			running = false
		end, ...)
	end
end

return Debounce