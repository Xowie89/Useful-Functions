-- HttpUtil.lua
-- HttpService wrappers with retries and JSON helpers
-- API (server):
--   HttpUtil.request(opts) -> ok:boolean, res:{ StatusCode:number, Success:boolean, Headers:table, Body:string, Json:any? }, errMsg?:string
--     opts = { method:string, url:string, headers?:table, body?:string|table, json?:boolean, retries?:number, backoff?:number }
--   HttpUtil.get(url, headers?, opts?) -> ok, res, err
--   HttpUtil.post(url, body, headers?, opts?) -> ok, res, err
--   HttpUtil.fetchJson(url, opts?) -> ok, json:any, err
--   HttpUtil.encode(value) -> string, HttpUtil.decode(str) -> any

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local HttpUtil = {}

local function toJSON(value): string
	return HttpService:JSONEncode(value)
end

local function fromJSON(str)
	return HttpService:JSONDecode(str)
end

local function withRetries(fn, retries: number?, backoff: number?)
	retries = retries or 2
	backoff = backoff or 1
	local attempt = 0
	while true do
		attempt += 1
		local ok, a, b, c = pcall(fn)
		if ok then return a, b, c end
		if attempt > retries then
			return nil, tostring(a)
		end
		task.wait(backoff * attempt)
	end
end

function HttpUtil.request(opts: { method: string, url: string, headers: table?, body: any?, json: boolean?, retries: number?, backoff: number? })
	assert(RunService:IsServer(), "HttpUtil.request should be used on the server")
	local method = string.upper(opts.method or "GET")
	local url = assert(opts.url, "url required")
	local headers = opts.headers or {}
	local bodyStr: string? = nil
	if opts.json then
		headers["Content-Type"] = headers["Content-Type"] or "application/json"
		if opts.body ~= nil then bodyStr = toJSON(opts.body) end
	else
		if type(opts.body) == "table" then
			-- If a table is passed without json=true, still JSON encode by default for safety
			bodyStr = toJSON(opts.body)
			headers["Content-Type"] = headers["Content-Type"] or "application/json"
		else
			bodyStr = opts.body
		end
	end

	local function doRequest()
		local res = HttpService:RequestAsync({
			Url = url,
			Method = method,
			Headers = headers,
			Body = bodyStr,
		})
		return res
	end

	local res, err = withRetries(doRequest, opts.retries, opts.backoff)
	if not res then
		return false, nil, err
	end

	-- Attach decoded JSON if content-type is JSON
	local contentType = ""
	for k, v in pairs(res.Headers or {}) do
		if string.lower(k) == "content-type" then contentType = string.lower(tostring(v)) break end
	end
	if string.find(contentType, "application/json", 1, true) then
		local ok, decoded = pcall(fromJSON, res.Body)
		if ok then res.Json = decoded end
	end
	return res.Success == true, res, nil
end

function HttpUtil.get(url: string, headers: table?, opts: {retries:number?, backoff:number?}?)
	return HttpUtil.request({ method = "GET", url = url, headers = headers or {}, retries = opts and opts.retries, backoff = opts and opts.backoff })
end

function HttpUtil.post(url: string, body: any, headers: table?, opts: {json:boolean?, retries:number?, backoff:number?}?)
	return HttpUtil.request({ method = "POST", url = url, headers = headers or {}, body = body, json = opts and opts.json, retries = opts and opts.retries, backoff = opts and opts.backoff })
end

function HttpUtil.fetchJson(url: string, opts: {retries:number?, backoff:number?}?)
	local ok, res, err = HttpUtil.get(url, nil, opts)
	if not ok then return false, nil, err end
	if res.Json ~= nil then return true, res.Json, nil end
	local ok2, decoded = pcall(fromJSON, res.Body)
	if ok2 then return true, decoded, nil end
	return false, nil, "Failed to decode JSON"
end

function HttpUtil.encode(value): string return toJSON(value) end
function HttpUtil.decode(str) return fromJSON(str) end

return HttpUtil