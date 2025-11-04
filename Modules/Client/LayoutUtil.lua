-- Modules/Client/LayoutUtil.lua
-- Helpers to create common UI layout instances with sane defaults

local LayoutUtil = {}

function LayoutUtil.createList(options)
	options = options or {}
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = options.fillDirection or Enum.FillDirection.Vertical
	layout.HorizontalAlignment = options.horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = options.verticalAlignment or Enum.VerticalAlignment.Top
	layout.Padding = options.padding or UDim.new(0, 8)
	layout.SortOrder = options.sortOrder or Enum.SortOrder.LayoutOrder
	if options.parent then layout.Parent = options.parent end
	return layout
end

function LayoutUtil.createGrid(options)
	options = options or {}
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = options.cellSize or UDim2.fromOffset(64, 64)
	layout.CellPadding = options.cellPadding or UDim2.fromOffset(8, 8)
	layout.HorizontalAlignment = options.horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = options.verticalAlignment or Enum.VerticalAlignment.Top
	if options.parent then layout.Parent = options.parent end
	return layout
end

function LayoutUtil.createTable(options)
	options = options or {}
	local layout = Instance.new("UITableLayout")
	layout.FillDirection = options.fillDirection or Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = options.horizontalAlignment or Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = options.verticalAlignment or Enum.VerticalAlignment.Top
	layout.Padding = options.padding or UDim.new(0, 8)
	if options.parent then layout.Parent = options.parent end
	return layout
end

function LayoutUtil.createPadding(options)
	options = options or {}
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = options.left or UDim.new(0, 8)
	pad.PaddingRight = options.right or UDim.new(0, 8)
	pad.PaddingTop = options.top or UDim.new(0, 8)
	pad.PaddingBottom = options.bottom or UDim.new(0, 8)
	if options.parent then pad.Parent = options.parent end
	return pad
end

return LayoutUtil
