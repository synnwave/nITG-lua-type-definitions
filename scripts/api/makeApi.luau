--!strict
-- lua api stolen from: https://gitlab.com/CraftedCart/notitg_docs/-/tree/master/lua

local fs = require("@lune/fs")
local process = require("@lune/process")
local net = require("@lune/net")

local function getArgTypes(arg)
	if typeof(arg) ~= "table" then return {} end

	local args = {}
	if arg.type.id == "or" and arg.type.types then
		for _, realType in arg.type.types do
			table.insert(args, realType.name or realType.id)
		end
	else
		table.insert(args, arg.type.name or arg.type.id)
	end

	return args
end

local function handleMethod(method)
	local thisMethod = {
		args = {},
		returns = getArgTypes(method.returns[1]),
		description = method.desc,
	}

	if method.params then
		for _, arg in method.params do
			table.insert(thisMethod.args, {
				name = arg.name,
				description = arg.desc,
				type = getArgTypes(arg),
			})
		end
	end

	if #thisMethod.args <= 0 then thisMethod.args = nil :: any end
	return thisMethod
end

local outputData = {
	classes = {},
	global = { vars = {}, funcs = {} },
}

local root = "scripts/api/"
for _, file in fs.readDir(root .. "lua") do
	local filePath = root .. `lua/{file}`
	local cachedJSONPath = root .. `json/{file}.json`
	local fileJSON = if fs.isFile(cachedJSONPath)
		then fs.readFile(cachedJSONPath)
		else process.spawn("luadoc", { filePath }).stdout
	if not fs.isFile(cachedJSONPath) then fs.writeFile(cachedJSONPath, fileJSON) end

	local decodedJson = net.jsonDecode(fileJSON)[1]
	if file == "global.lua" then
		for _, var in decodedJson.data do
			var = var.value
			outputData.global.vars[var.name] = {
				description = `{var.short_desc}{var.desc}`,
				type = getArgTypes(var)[1],
			}
		end
		for _, method in decodedJson.functions do
			if method.name:sub(1, 2) == "__" then continue end -- ignore metamethods
			outputData.global.funcs[method.name] = handleMethod(method)
		end
		continue
	end

	if decodedJson.classes then
		local thisClass = decodedJson.classes[1]
		local thisData = {
			inherits = thisClass.inherits_from[1],
		}

		for _, method in thisClass.methods do
			if method.name:sub(1, 2) == "__" then continue end -- ignore metamethods
			thisData[method.name] = handleMethod(method)
		end

		outputData.classes[thisClass.name] = thisData
	end
end

fs.writeFile(root .. "nITG-API.json", net.jsonEncode(outputData))
return nil
