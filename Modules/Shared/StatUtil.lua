-- Modules/Shared/StatUtil.lua
-- Simple statistical helpers: EMA, running mean/min/max

local StatUtil = {}

function StatUtil.ema(prev, x, alpha)
	alpha = math.clamp(alpha or 0.5, 0, 1)
	if prev == nil then return x end
	return alpha * x + (1 - alpha) * prev
end

function StatUtil.Running()
	local self = {
		count = 0,
		sum = 0,
		min = math.huge,
		max = -math.huge,
	}
	function self:push(x)
		self.count += 1
		self.sum += x
		if x < self.min then self.min = x end
		if x > self.max then self.max = x end
	end
	function self:mean()
		return (self.count > 0) and (self.sum / self.count) or 0
	end
	return self
end

return StatUtil
