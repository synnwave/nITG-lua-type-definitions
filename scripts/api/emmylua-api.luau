local apiLinks = require("apiLinks")

local function toLuaType(arg, useNil: boolean?): string
	arg = arg:gsub("_", ", ") -- we don't have a way to check if the argument is an union or returns multiple values... we will use underscores as commas instead
	arg = arg:gsub("function", "fun(any): any"):gsub("Array", "[]")

	if arg == "array" then
		arg = "any[]"
	elseif arg == "table" then
		arg = "table<any, any>"
	elseif arg == "void" or arg == "never" or arg == "" or arg == " " then
		arg = if useNil then "nil" else ""
	elseif arg == "multiple" then
		arg = "...any"
	elseif arg == "The" or arg == "sync" then -- unknown args (wtf is "The")
		arg = "any"
	end

	return arg or ""
end

local function stringifyFunc(funcName, func)
	local argDeclarations = ""
	local args = ""
	if func.args then
		for _, argData in func.args do
			local argName = argData.name
			local type = ""
			if typeof(argData.type) == "string" then
				type = argData.type
			else
				for i, argType in argData.type do
					type ..= `{if i > 1 then " | " else ""}{toLuaType(argType)}`
				end
			end

			argDeclarations ..= `\n---@param {argName} {type}{if argData.description
				then ` {argData.description}`
				else ""}`
			args ..= ` {argName},`
		end
	end

	if func.returns then
		local thisReturns = ""
		if #func.returns > 0 then
			for i, returnType in func.returns do
				thisReturns ..= `{if i > 1 then " | " else ""}{toLuaType(returnType or i > 1)}`
			end
		end
		if thisReturns:len() > 1 then
			argDeclarations ..= "\n---@return " .. thisReturns
		end
	end

	return `{argDeclarations}\nfunction {funcName}({args:sub(2, -2)}) end`
end

local function toApiLink(className)
	local apiLink = className
	if apiLinks.aliases[className] then
		apiLink = `[{className}]({apiLinks.apiRefLink:gsub("{CLASS}", apiLinks.aliases[className])})`
	end
	return apiLink
end

return function(jsonData, externalApi, xmlPath)
	local constants = "\n\n--> CONSTANTS"
	do --> Globals
		for constantType, constant in jsonData.global do
			if constantType == "vars" then
				for varName, value in constant do
					constants ..= `\n\n---@type {value.type}\n{varName} = nil`
				end
			end

			if constantType == "funcs" then
				for funcName, func in constant do
					constants ..= `\n\n{stringifyFunc(funcName, func)}`
				end
			end
		end
	end

	local classes = "\n\n--> CLASSES"
	do --> Classes
		for className, classData in jsonData.classes do
			local inherits = classData.inherits
			local startString =
				`-------> CLASS: {toApiLink(className)}{if inherits then ` ({toApiLink(inherits)})` else ""} <----`
			local thisOutput = "\n\n" .. startString

			thisOutput ..= `\n---@class {className}{if inherits then `: {inherits}` else ""} {toApiLink(className)}`
			thisOutput ..= `\nlocal {className} = \{}`
			for method, methodData in classData do
				if typeof(methodData) ~= "table" then continue end
				thisOutput ..= `\n{stringifyFunc(`{className}:{method}`, methodData)}`
			end

			thisOutput ..= `\n{string.rep("-", startString:len())}`
			classes ..= thisOutput
		end
	end

	--> External Api Data
	local externalApiConstants = "\n\n--> EXTERNAL API"
	for var, type in externalApi.vars do
		externalApiConstants ..= `\n\n---@type {type}\n{var} = nil`
	end

	for funcName, func in externalApi.funcs do
		externalApiConstants ..= `\n\n{stringifyFunc(funcName, func)}`
	end

	--> XML Data
	local xmlData = "\n\n--> XML DATA\n"
	if xmlPath then
		require("getXML")(xmlPath, false, function(name: string, type: string, headerData: string?)
			if headerData then
				xmlData ..= `\n{headerData}\n`
				return
			end
			xmlData ..= `\n\n---@type {type}\n{name} = \{}`
		end)
	end

	return classes .. constants .. externalApiConstants .. xmlData
end
