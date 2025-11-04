-- WebhookUtil.lua
-- Minimal webhook sender using HttpService (e.g., Discord)

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
assert(RunService:IsServer(), "WebhookUtil must be used on the server")

local DEFAULT_HEADERS = { ["Content-Type"] = "application/json" }

local M = {}

-- postJson(url, tablePayload, opts?) -> ok, resultOrErr
-- opts = { headers = {..}, compress = false, httpService = HttpService }
function M.postJson(url, payload, opts)
	assert(type(url) == "string" and #url > 0, "url required")
	opts = opts or {}
	local headers = opts.headers or DEFAULT_HEADERS
	local svc = opts.httpService or HttpService
	local body = svc:JSONEncode(payload)
	local ok, res = pcall(function()
		return svc:RequestAsync({ Url = url, Method = "POST", Headers = headers, Body = body })
	end)
	if not ok then return false, res end
	if res.Success then return true, res end
	return false, res
end

return M
