--https://github.com/XeroOl/notitg-xml-to-emmylua/blob/main/converter.lua

local fs = require("@lune/fs")
local luau = require("@lune/luau")

-- actor types to recognise in xml
-- There are more, but these are the ones common in modding

local types = {
	Actor = true,
	ActorFrame = true,
	ActorFrameTexture = true,
	ActorProxy = true,
	ActorScroller = true,
	ActorSound = true,
	BitmapText = true,
	Model = true,
	Polygon = true,
	Sprite = true,
	Quad = true,
}

local function validateLua(str)
	return (pcall(function() luau.compile(str) end))
end

return function(inputXML)
	local out = ""
	local strings, i = {}, 0
	local contents = fs.readFile(inputXML):gsub('".-"', function(str)
		i += 1
		strings[tostring(i)] = str:gsub("\n", "\\n"):sub(2, -2)
		return `"{i}"`
	end)

	local headers = {}
	for tag, properties in contents:gmatch("[^<]*<([^ \n>=]+) *([^>]-) */?>\n?") do
		local type = types[tag] and tag or "Actor"
		local name
		for prop, id in properties:gmatch('([^=]-) *= *"(%d+)" *') do
			local body = strings[id]
			if prop == "Type" then type = body end
			if prop == "Name" or prop == "Var" then name = body end
			if prop:sub(-7) == "Command" then name = name or body:match("(%w+) ?= ?self") end
		end

		if name and validateLua(name .. " = {}") then
			local count = #name - #name:gsub("[.[]", "")
			if count > 0 then
				local header = name:gsub("%.", " = {"):gsub("(%b[])", " = {%1"):gsub("{[^{]*$", "{") .. ("}"):rep(count)
				local headerName = header:split("=")[1]
				if not headers[header] and validateLua(header) and headerName then
					out ..= `\ndeclare {headerName}: \{ {type} }`
					headers[header] = true
				end
				continue
			end
			out ..= `\ndeclare {name}: {type}`
		end
	end

	return out
end
