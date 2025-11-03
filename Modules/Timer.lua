-- Timer.lua
-- Simple setTimeout and setInterval utilities using task.spawn
-- API:
--   Timer.setTimeout(fn, delaySeconds) -> handle { Stop }
--   Timer.setInterval(fn, intervalSeconds) -> handle { Stop }
--   Timer.wait(seconds) -> () yields for seconds

local Timer = {}

export type Handle = { Stop: (self: Handle) -> () }

function Timer.wait(seconds: number)
	local t = tonumber(seconds) or 0
	local elapsed = 0
	while elapsed < t do
		elapsed += task.wait(math.min(0.5, t - elapsed))
	end
end

function Timer.setTimeout(fn: () -> (), delaySeconds: number): Handle
	local running = true
	task.spawn(function()
		Timer.wait(delaySeconds)
		if running then
			local ok, err = pcall(fn)
			if not ok then warn("setTimeout error:", err) end
		end
	end)
	return {
		Stop = function()
			running = false
		end,
	}
end

function Timer.setInterval(fn: () -> (), intervalSeconds: number): Handle
	local running = true
	task.spawn(function()
		while running do
			local ok, err = pcall(fn)
			if not ok then warn("setInterval error:", err) end
			Timer.wait(intervalSeconds)
		end
	end)
	return {
		Stop = function()
			running = false
		end,
	}
end

return Timer