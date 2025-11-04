-- Modules/Client/HighlightUtil.lua
-- Helpers for creating and managing Highlight adornments

local HighlightUtil = {}

-- Show a Highlight on a target Instance (e.g., Model or BasePart)
-- options: { color: Color3, fillTransparency: number, outlineTransparency: number, duration: number, parent: Instance }
-- returns: highlight, cleanup()
function HighlightUtil.show(target, options)
	assert(target, "HighlightUtil.show requires a target instance")
	options = options or {}

	local highlight = Instance.new("Highlight")
	highlight.Adornee = target
	highlight.FillColor = options.color or Color3.fromRGB(255, 213, 89)
	highlight.OutlineColor = options.color or Color3.fromRGB(255, 213, 89)
	highlight.FillTransparency = options.fillTransparency or 0.6
	highlight.OutlineTransparency = options.outlineTransparency or 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = options.parent or target

	local function cleanup()
		if highlight then
			highlight:Destroy()
			highlight = nil
		end
	end

	local duration = options.duration
	if duration and duration > 0 then
		task.delay(duration, function()
			cleanup()
		end)
	end

	return highlight, cleanup
end

return HighlightUtil
