-- SoundUtil.lua
-- Helpers for playing and preloading sounds
-- API:
--   SoundUtil.play(soundOrId, opts?) -> sound: Sound, handle: { Stop: ()->(), FadeOut: (seconds:number)->(), Destroy: ()->() }
--   SoundUtil.preload(idsOrSounds: {string|Sound}) -> ()  -- yields until preloaded
-- opts:
--   parent: Instance? (default workspace), volume: number?, looped: boolean?, playbackSpeed: number?, timePosition: number?
--   rolloffMaxDistance: number?, emitterSize: number?, startPaused: boolean?, destroyOnEnd: boolean? (default true)
--   fadeIn: number?, fadeOut: number?

local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SoundUtil = {}

local function getSound(soundOrId: any): Sound
	if typeof(soundOrId) == "Instance" and soundOrId:IsA("Sound") then
		return soundOrId
	end
	local s = Instance.new("Sound")
	if type(soundOrId) == "string" and soundOrId ~= "" then
		s.SoundId = soundOrId
	end
	return s
end

function SoundUtil.preload(list: {any})
	local assets = {}
	for _, item in ipairs(list) do
		if typeof(item) == "Instance" and item:IsA("Sound") then
			assets[#assets+1] = item
		elseif type(item) == "string" then
			local s = Instance.new("Sound")
			s.SoundId = item
			assets[#assets+1] = s
		end
	end
	if #assets > 0 then
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
		for _, s in ipairs(assets) do
			if s.Parent == nil then s:Destroy() end
		end
	end
end

local function tweenProperty(inst: Instance, info: TweenInfo, props: {[string]: any})
	local t = TweenService:Create(inst, info, props)
	t:Play()
	return t
end

function SoundUtil.play(soundOrId: any, opts: {
	parent: Instance?, volume: number?, looped: boolean?, playbackSpeed: number?, timePosition: number?,
	rolloffMaxDistance: number?, emitterSize: number?, startPaused: boolean?, destroyOnEnd: boolean?, fadeIn: number?, fadeOut: number?
}?)
	opts = opts or {}
	local sound = getSound(soundOrId)
	sound.Parent = opts.parent or workspace
	if type(opts.volume) == "number" then sound.Volume = opts.volume end
	if type(opts.looped) == "boolean" then sound.Looped = opts.looped end
	if type(opts.playbackSpeed) == "number" then sound.PlaybackSpeed = opts.playbackSpeed end
	if type(opts.timePosition) == "number" then sound.TimePosition = opts.timePosition end
	if type(opts.rolloffMaxDistance) == "number" then sound.RollOffMaxDistance = opts.rolloffMaxDistance end
	if type(opts.emitterSize) == "number" then sound.EmitterSize = opts.emitterSize end

	local destroyOnEnd = opts.destroyOnEnd ~= false
	local fadeIn = tonumber(opts.fadeIn)
	local fadeOut = tonumber(opts.fadeOut)
	local originalVolume = sound.Volume

	if fadeIn and fadeIn > 0 then
		sound.Volume = 0
	end

	local stopped = false
	local currentTween: Tween? = nil

	local function doFadeOut(seconds: number)
		if seconds and seconds > 0 then
			if currentTween then currentTween:Cancel() end
			currentTween = tweenProperty(sound, TweenInfo.new(seconds), { Volume = 0 })
			currentTween.Completed:Wait()
		end
	end

	local function stop()
		if stopped then return end
		stopped = true
		if fadeOut and fadeOut > 0 then
			doFadeOut(fadeOut)
		end
		sound:Stop()
		if destroyOnEnd then
			sound:Destroy()
		end
	end

	if not opts.startPaused then
		sound:Play()
	end

	if fadeIn and fadeIn > 0 then
		if currentTween then currentTween:Cancel() end
		currentTween = tweenProperty(sound, TweenInfo.new(fadeIn), { Volume = originalVolume })
	end

	local endedConn
	if destroyOnEnd then
		endedConn = sound.Ended:Connect(function()
			if stopped then return end
			stopped = true
			if destroyOnEnd and sound.Parent then
				sound:Destroy()
			end
		end)
	end

	return sound, {
		Stop = stop,
		FadeOut = function(seconds: number)
			doFadeOut(seconds)
			sound:Stop()
			if destroyOnEnd then sound:Destroy() end
		end,
		Destroy = function()
			if endedConn then endedConn:Disconnect() end
			if sound.IsPlaying then sound:Stop() end
			sound:Destroy()
		end,
	}
end

return SoundUtil