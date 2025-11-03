-- PlayerUtil.lua
-- Player and character helpers usable on client/server
-- API:
--   getPlayerFromCharacter(model) -> Player?
--   waitForCharacter(player, timeout?) -> Model?
--   waitForHumanoid(target: Player|Model, timeout?) -> Humanoid?
--   waitForHRP(target: Player|Model, timeout?) -> BasePart?
--   isAlive(target: Player|Model|Humanoid) -> boolean
--   getHumanoid(target) -> Humanoid?
--   getHRP(target) -> BasePart?

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerUtil = {}

function PlayerUtil.getPlayerFromCharacter(model: Instance): Player?
	if typeof(model) == "Instance" and model:IsA("Model") then
		return Players:GetPlayerFromCharacter(model)
	end
	return nil
end

local function resolveCharacter(target: any): Model?
	if typeof(target) == "Instance" then
		if target:IsA("Player") then return target.Character end
		if target:IsA("Model") then return target end
	end
	return nil
end

function PlayerUtil.getHumanoid(target: any): Humanoid?
	local char = resolveCharacter(target)
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

function PlayerUtil.getHRP(target: any): BasePart?
	local char = resolveCharacter(target)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") :: BasePart
end

function PlayerUtil.waitForCharacter(player: Player, timeout: number?): Model?
	local deadline = timeout and (time() + timeout) or nil
	while true do
		local char = player.Character
		if char then return char end
		if deadline and time() > deadline then return nil end
		if RunService:IsClient() then
			player.CharacterAdded:Wait()
		else
			local ev = player.CharacterAdded
			local fired = false
			local conn
			conn = ev:Connect(function() fired = true if conn then conn:Disconnect() end end)
			while not fired do
				if deadline and time() > deadline then if conn then conn:Disconnect() end; return nil end
				task.wait(0.1)
			end
		end
	end
end

function PlayerUtil.waitForHumanoid(target: Player | Model, timeout: number?): Humanoid?
	local char = resolveCharacter(target)
	if not char then return nil end
	local deadline = timeout and (time() + timeout) or nil
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then return hum end
	local conn
	local found: Humanoid? = nil
	conn = char.ChildAdded:Connect(function(c)
		if c:IsA("Humanoid") then
			found = c
			if conn then conn:Disconnect() end
		end
	end)
	while not found do
		if deadline and time() > deadline then break end
		task.wait(0.1)
	end
	if conn then conn:Disconnect() end
	return found
end

function PlayerUtil.waitForHRP(target: Player | Model, timeout: number?): BasePart?
	local char = resolveCharacter(target)
	if not char then return nil end
	local deadline = timeout and (time() + timeout) or nil
	local part = char:FindFirstChild("HumanoidRootPart")
	if part then return part :: BasePart end
	local conn
	local found: BasePart? = nil
	conn = char.ChildAdded:Connect(function(c)
		if c.Name == "HumanoidRootPart" and c:IsA("BasePart") then
			found = c
			if conn then conn:Disconnect() end
		end
	end)
	while not found do
		if deadline and time() > deadline then break end
		task.wait(0.1)
	end
	if conn then conn:Disconnect() end
	return found
end

function PlayerUtil.isAlive(target: any): boolean
	local hum: Humanoid? = nil
	if typeof(target) == "Instance" and target:IsA("Humanoid") then
		hum = target
	else
		hum = PlayerUtil.getHumanoid(target)
	end
	if not hum then return false end
	return hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
end

return PlayerUtil