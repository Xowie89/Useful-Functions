-- ViewportUtil.lua
-- Helpers to create and render models in a ViewportFrame

local RunService = game:GetService("RunService")
assert(RunService:IsClient(), "ViewportUtil must be required on the client")

local M = {}

-- createViewport(sizeUDim2?, bgTransparency?) -> viewportFrame, worldModel, camera
function M.createViewport(size, bg)
	local vpf = Instance.new("ViewportFrame")
	vpf.Name = "Viewport"
	vpf.BackgroundTransparency = bg == nil and 1 or bg
	vpf.Size = size or UDim2.fromScale(1,1)
	local wm = Instance.new("WorldModel")
	wm.Parent = vpf
	local cam = Instance.new("Camera")
	cam.Parent = vpf
	vpf.CurrentCamera = cam
	return vpf, wm, cam
end

-- setModel(viewportFrame, model, opts?) centers model and fits camera
function M.setModel(vpf, model, opts)
	assert(vpf and vpf:IsA("ViewportFrame"), "ViewportFrame required")
	assert(model and model:IsA("Model"), "Model required")
	opts = opts or {}
	local wm = vpf:FindFirstChildOfClass("WorldModel") or Instance.new("WorldModel")
	wm.Parent = vpf
	model:Clone().Parent = wm
	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primary then return end
	local cf, size = model:GetBoundingBox()
	local radius = (size.Magnitude)/2
	local cam = vpf.CurrentCamera or Instance.new("Camera")
	cam.Parent = vpf
	vpf.CurrentCamera = cam
	local distance = radius * 2
	local lookAt = cf.Position
	cam.CFrame = CFrame.new(lookAt + Vector3.new(distance, distance, distance), lookAt)
end

return M
