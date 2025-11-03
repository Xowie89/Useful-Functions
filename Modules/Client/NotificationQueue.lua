-- NotificationQueue.lua
-- Client-side queued and stacked toast notifications
-- API (client):
--   local nq = NotificationQueue.new(opts?)
--   nq:show(text, opts?) -> handle
--   nq:enqueue(text, opts?) -> () -- alias of show
--   nq:clear() -> ()
--   nq:setMaxVisible(n)
--   nq:setPosition(position: UDim2, anchorPoint: Vector2?)
--   nq:setGap(pixels)
--
-- opts: { maxVisible:number?=3, gap:number?=8, position:UDim2? (default top-center), anchorPoint:Vector2? }

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local NotificationQueue = {}
NotificationQueue.__index = NotificationQueue

local function getPlayerGui(): PlayerGui
	local p = Players.LocalPlayer
	if not p then error("NotificationQueue must be used from a LocalScript") end
	local pg = p:FindFirstChildOfClass("PlayerGui")
	if not pg then
		p.ChildAdded:Wait()
		pg = p:FindFirstChildOfClass("PlayerGui")
	end
	return pg
end

local function makeToast(text: string, theme, size, corner, padding)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = theme.bg
	frame.BackgroundTransparency = 0.1
	frame.Size = size
	frame.BorderSizePixel = 0

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, corner)
	uicorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.TextColor3 = theme.fg
	label.Size = UDim2.new(1, -padding*2, 1, -padding*2)
	label.Position = UDim2.new(0, padding, 0, padding)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = frame

	frame.Visible = false
	return frame, label
end

function NotificationQueue.new(opts)
	assert(RunService:IsClient(), "NotificationQueue must be created on the client")
	opts = opts or {}
	local self = setmetatable({}, NotificationQueue)
	self._maxVisible = opts.maxVisible or 3
	self._gap = opts.gap or 8
	self._position = opts.position or UDim2.new(0.5, 0, 0.12, 0)
	self._anchorPoint = opts.anchorPoint or Vector2.new(0.5, 0)
	self._theme = { bg = Color3.fromRGB(20,20,20), fg = Color3.new(1,1,1) }
	self._size = UDim2.fromOffset(380, 48)
	self._corner = 8
	self._padding = 12
	self._fade = 0.2
	self._duration = 2.5

	local pg = getPlayerGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NotificationQueue"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = pg
	self._gui = screenGui

	self._visible = {} -- { {frame=Frame, endAt=number, conn=RBXScriptConnection?} }
	self._queue = {} -- { {text=string, opts=table} }
	self._running = true

	-- heartbeat update to expire and reposition
	self._heartbeat = RunService.Heartbeat:Connect(function()
		self:_update()
	end)

	return self
end

function NotificationQueue:destroy()
	self._running = false
	if self._heartbeat then self._heartbeat:Disconnect() end
	self:clear()
	if self._gui then self._gui:Destroy() end
end

function NotificationQueue:setMaxVisible(n) self._maxVisible = math.max(1, n or 1) end
function NotificationQueue:setGap(px) self._gap = math.max(0, px or 0) end
function NotificationQueue:setPosition(pos: UDim2, anchor: Vector2?)
	self._position = pos
	if anchor then self._anchorPoint = anchor end
	self:_reposition()
end

function NotificationQueue:clear()
	for _, e in ipairs(self._visible) do
		if e.conn then e.conn:Disconnect() end
		e.frame:Destroy()
	end
	self._visible = {}
	self._queue = {}
end

local function tween(o, info, props)
	local t = TweenService:Create(o, info, props)
	t:Play()
	return t
end

function NotificationQueue:_spawn(text, opts)
	opts = opts or {}
	local theme = opts.theme or self._theme
	local size = opts.size or self._size
	local corner = opts.corner or self._corner
	local padding = opts.padding or self._padding
	local fade = opts.fade or self._fade
	local duration = opts.duration or self._duration

	local frame, label = makeToast(text, theme, size, corner, padding)
	frame.AnchorPoint = self._anchorPoint
	frame.Position = self._position
	frame.Parent = self._gui
	frame.Visible = true
	frame.BackgroundTransparency = 1
	label.TextTransparency = 1

	tween(frame, TweenInfo.new(fade, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.1 })
	tween(label, TweenInfo.new(fade), { TextTransparency = 0 })

	local entry = { frame = frame, endAt = time() + duration, conn = nil, fade = fade }
	table.insert(self._visible, 1, entry) -- add to top of stack
	self:_reposition()

	local closed = false
	local function close()
		if closed then return end
		closed = true
		-- fade out and remove
		tween(frame, TweenInfo.new(fade), { BackgroundTransparency = 1 })
		tween(label, TweenInfo.new(fade), { TextTransparency = 1 })
		task.delay(fade, function()
			for i, e in ipairs(self._visible) do
				if e.frame == frame then
					table.remove(self._visible, i)
					break
				end
			end
			frame:Destroy()
			self:_reposition()
			self:_drainQueue()
		end)
	end

	-- auto close at endAt
	task.delay(duration, close)

	return {
		Close = close,
		Destroy = close,
	}
end

function NotificationQueue:_reposition()
	-- Stack visible toasts downward from position with gap
	local pos = self._position
	local yOffset = 0
	for i, e in ipairs(self._visible) do
		local target = pos + UDim2.new(0, 0, 0, yOffset)
		tween(e.frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = target })
		yOffset = yOffset + e.frame.AbsoluteSize.Y + self._gap
		if i >= self._maxVisible then break end
	end
	-- hide extras beyond maxVisible
	for i = self._maxVisible + 1, #self._visible do
		local e = self._visible[i]
		e.frame.Visible = false
	end
end

function NotificationQueue:_drainQueue()
	while #self._queue > 0 and #self._visible < self._maxVisible do
		local item = table.remove(self._queue, 1)
		self:_spawn(item.text, item.opts)
	end
end

function NotificationQueue:_update()
	if not self._running then return end
	-- remove expired beyond duration (redundant with delay close but safe)
	local now = time()
	local changed = false
	for i = #self._visible, 1, -1 do
		local e = self._visible[i]
		if now >= e.endAt then
			e.frame.Visible = false
			e.frame:Destroy()
			table.remove(self._visible, i)
			changed = true
		end
	end
	if changed then
		self:_reposition()
		self:_drainQueue()
	end
end

function NotificationQueue:show(text: string, opts)
	if #self._visible >= self._maxVisible then
		table.insert(self._queue, { text = text, opts = opts })
		return { Close = function() end, Destroy = function() end }
	end
	return self:_spawn(text, opts)
end

function NotificationQueue:enqueue(text: string, opts)
	return self:show(text, opts)
end

return NotificationQueue