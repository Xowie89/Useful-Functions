-- TimeUtil.lua
-- Time helpers: formatting durations and ISO timestamps
-- API:
--   nowUnix() -> number
--   formatDuration(seconds) -> "HH:MM:SS" or "MM:SS"
--   humanize(seconds) -> "1h 2m 3s"
--   iso8601(epochSeconds?) -> string (UTC)
--   localISO(epochSeconds?) -> string (local time)

local TimeUtil = {}

local function pad2(n: number): string
	if n < 10 then return "0" .. tostring(n) end
	return tostring(n)
end

function TimeUtil.nowUnix(): number
	return os.time()
end

function TimeUtil.formatDuration(seconds: number): string
	seconds = math.max(0, math.floor(seconds or 0))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%s:%s:%s", pad2(h), pad2(m), pad2(s))
	else
		return string.format("%s:%s", pad2(m), pad2(s))
	end
end

function TimeUtil.humanize(seconds: number): string
	seconds = math.max(0, math.floor(seconds or 0))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	local parts = {}
	if h > 0 then table.insert(parts, tostring(h) .. "h") end
	if m > 0 then table.insert(parts, tostring(m) .. "m") end
	if s > 0 or #parts == 0 then table.insert(parts, tostring(s) .. "s") end
	return table.concat(parts, " ")
end

function TimeUtil.iso8601(epoch: number?): string
	return os.date("!%Y-%m-%dT%H:%M:%SZ", epoch or os.time())
end

function TimeUtil.localISO(epoch: number?): string
	return os.date("%Y-%m-%dT%H:%M:%S%z", epoch or os.time())
end

return TimeUtil