-- TeleportUtil.lua
-- Utilities for teleporting players:
-- 1) Within the same server (move character to a position/part/cframe)
-- 2) Between places/servers (TeleportService helpers with retries)
--
-- API (server-side recommended):
--   TeleportUtil.teleportInServer(target: Player|Model, destination: CFrame|Vector3|BasePart, options?) -> boolean
--     options: { keepOrientation: boolean?, offset: Vector3?, unseat: boolean? }
--
--   TeleportUtil.teleportToPlace(placeId: number, players: Player|{Player}, teleportData?: any, options?) -> (boolean, string?)
--     options: { retries: number?, backoff: number? } -- backoff in seconds
--
--   TeleportUtil.teleportToPlaceInstance(placeId: number, jobId: string, players: Player|{Player}, teleportData?: any, options?) -> (boolean, string?)
--   TeleportUtil.reserveServer(placeId: number) -> (string, string) -- accessCode, reservedServerId
--   TeleportUtil.teleportToPrivateServer(placeId: number, players: Player|{Player}, teleportData?: any, options?) -> (boolean, string?, string?)
--     -- returns (ok, errMsg, accessCode)
--
-- Notes:
-- - Call from server when using TeleportService. Client teleports are allowed but server is best practice.
-- - teleportInServer works on server and affects character physics safely.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local TeleportUtil = {}

export type InServerOptions = {
	keepOrientation: boolean?,
	offset: Vector3?,
	unseat: boolean?,
}

local function toPlayerArray(p: any): {Player}
	if typeof(p) == "Instance" and p:IsA("Player") then
		return { p }
	elseif type(p) == "table" then
		-- assume already array of players
		return p
	else
		error("Expected Player or {Player}")
	end
end

local function resolveCharacter(target: any): Model?
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			return target.Character
		elseif target:IsA("Model") then
			return target
		end
	end
	return nil
end

local function getHRP(character: Model): BasePart?
	return character:FindFirstChild("HumanoidRootPart") :: BasePart
end

local function computeDestinationCFrame(dest: any, currentCF: CFrame?, opts: InServerOptions?): CFrame
	opts = opts or {}
	local baseCF: CFrame
	if typeof(dest) == "CFrame" then
		baseCF = dest
	elseif typeof(dest) == "Vector3" then
		baseCF = CFrame.new(dest)
	elseif typeof(dest) == "Instance" and dest:IsA("BasePart") then
		-- Place above the part surface by a small amount
		local upOffset = Vector3.new(0, (dest.Size.Y * 0.5) + 3, 0)
		baseCF = dest.CFrame + upOffset
	else
		error("destination must be CFrame | Vector3 | BasePart")
	end

	if opts.keepOrientation and currentCF then
		-- keep existing orientation (yaw/pitch/roll)
		local px, py, pz = baseCF:GetComponents()
		local _, rY, _ = currentCF:ToOrientation()
		local pos = Vector3.new(px, py, pz)
		return CFrame.new(pos) * CFrame.Angles(0, rY, 0)
	end

	if opts.offset then
		baseCF = baseCF + opts.offset
	end
	return baseCF
end

-- Teleport within the same server by repositioning the character safely
function TeleportUtil.teleportInServer(target: Player | Model, destination: any, options: InServerOptions?): boolean
	local character = resolveCharacter(target)
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local hrp = getHRP(character)
	if not humanoid or not hrp then return false end

	options = options or {}
	if options.unseat then
		-- ensure not seated to avoid seat weld fighting CFrame
		humanoid.Sit = false
		RunService.Heartbeat:Wait()
	end

	local destCF = computeDestinationCFrame(destination, hrp.CFrame, options)

	-- Prefer Model:SetPrimaryPartCFrame when possible for coherence
	local prevPrimary = character.PrimaryPart
	if not prevPrimary then
		character.PrimaryPart = hrp
	end

	-- Temporarily disable auto-rotate to reduce physics jitter
	local autoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	-- Anchor briefly to avoid physics impulses during teleport
	local wasAnchored = hrp.Anchored
	hrp.Anchored = true

	-- Move
	character:SetPrimaryPartCFrame(destCF)

	-- restore
	hrp.Anchored = wasAnchored
	humanoid.AutoRotate = autoRotate
	if not prevPrimary then
		character.PrimaryPart = nil
	end

	return true
end

-- Internal: perform a TeleportService operation with retries
local function withRetries(fn, retries: number?, backoff: number?)
	retries = retries or 2
	backoff = backoff or 1
	local attempt = 0
	while true do
		attempt += 1
		local ok, err = pcall(fn)
		if ok then return true end
		if attempt > retries then
			return false, tostring(err)
		end
		task.wait(backoff * attempt)
	end
end

-- Teleport multiple players (or a single player) to a place
function TeleportUtil.teleportToPlace(placeId: number, players: Player | {Player}, teleportData: any?, options: {retries: number?, backoff: number?}?): (boolean, string?)
	assert(RunService:IsServer(), "teleportToPlace should be called from the server")
	local playerList = toPlayerArray(players)
	local teleportOptions = Instance.new("TeleportOptions")
	if teleportData ~= nil then
		teleportOptions:SetTeleportData(teleportData)
	end
	local function doTeleport()
		TeleportService:TeleportAsync(placeId, playerList, teleportOptions)
	end
	return withRetries(doTeleport, options and options.retries or nil, options and options.backoff or nil)
end

function TeleportUtil.teleportToPlaceInstance(placeId: number, jobId: string, players: Player | {Player}, teleportData: any?, options: {retries: number?, backoff: number?}?): (boolean, string?)
	assert(RunService:IsServer(), "teleportToPlaceInstance should be called from the server")
	local playerList = toPlayerArray(players)
	local teleportOptions = Instance.new("TeleportOptions")
	if teleportData ~= nil then
		teleportOptions:SetTeleportData(teleportData)
	end
	local function doTeleport()
		TeleportService:TeleportToPlaceInstance(placeId, jobId, playerList, teleportOptions)
	end
	return withRetries(doTeleport, options and options.retries or nil, options and options.backoff or nil)
end

-- Reserve a private server for a place, returns (accessCode, reservedServerId)
function TeleportUtil.reserveServer(placeId: number): (string, string)
	assert(RunService:IsServer(), "reserveServer should be called from the server")
	local code, reservedId = TeleportService:ReserveServer(placeId)
	return code, reservedId
end

-- Reserve and teleport players to a private server. Returns (ok, errMsg, accessCode)
function TeleportUtil.teleportToPrivateServer(placeId: number, players: Player | {Player}, teleportData: any?, options: {retries: number?, backoff: number?}?): (boolean, string?, string?)
	assert(RunService:IsServer(), "teleportToPrivateServer should be called from the server")
	local accessCode, _ = TeleportUtil.reserveServer(placeId)
	local playerList = toPlayerArray(players)
	local teleportOptions = Instance.new("TeleportOptions")
	if teleportData ~= nil then
		teleportOptions:SetTeleportData(teleportData)
	end
	local function doTeleport()
		TeleportService:TeleportToPrivateServer(placeId, accessCode, playerList, teleportOptions)
	end
	local ok, err = withRetries(doTeleport, options and options.retries or nil, options and options.backoff or nil)
	return ok, err, accessCode
end

return TeleportUtil