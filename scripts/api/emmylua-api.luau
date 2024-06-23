local function toLuaType(arg, useNil: boolean?): string
	if arg == "array" then
		arg = "table<number, any>"
	elseif arg == "table" then
		arg = "table<any, any>"
	elseif arg == "void" or arg == "never" or arg == "" or arg == " " then
		arg = if useNil then "nil" else ""
	elseif arg == "function" then
		arg = "fun(any): any"
	elseif arg == "multiple" then
		arg = "...any"
	elseif arg == "The" or arg == "sync" then -- unknown args (wtf is "The")
		arg = "any"
	end

	return arg or ""
end

local function stringifyMethod(methodName, methodData, class: string?): string
	if typeof(methodData) ~= "table" then return "" end

	local args = ""
	if methodData.args then
		for _, argData in methodData.args do
			local argName = argData.name
			local type = ""
			if typeof(argData.type) == "string" then
				type = argData.type
			else
				for i, argType in argData.type do
					type ..= `{if i > 1 then " | " else ""}{toLuaType(argType)}`
				end
			end
			args ..= ` {argName}: {type},`
		end
	end

	local returns = ""
	if methodData.returns then
		for i, returnType in methodData.returns do
			returns ..= `{if i > 1 then " | " else ""}{toLuaType(returnType, i > 1)}`
		end
	end

	returns = toLuaType(returns)
	returns = if returns:find(",") then `({returns})` else returns
	local spacer = if returns:len() > 2 then ": " else ""
	return `{methodName} fun({if class then `self: {class}{if args:len() > 2 then ", " else ""}` else ""}{args:sub(
		2,
		-2
	)}){spacer}{returns}`
end

local function stringifyGlobalFunc(funcName, func)
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

			argDeclarations ..= `---@param {argName} {type}`
			args ..= ` {argName},`
		end
	end

	if func.returns then
		argDeclarations ..= "\n---@return "
		if #func.returns > 0 then
			for i, returnType in func.returns do
				argDeclarations ..= `{if i > 1 then " | " else ""}{toLuaType(returnType, i > 1)}`
			end
		else
			argDeclarations ..= "nil"
		end
	end

	return `{argDeclarations}\nfunction {funcName}({args:sub(2, -2)}) end`
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
					constants ..= `\n\n{stringifyGlobalFunc(funcName, func)}`
				end
			end
		end
	end

	local classes = "\n\n--> CLASSES"
	do --> Classes
		for className, classData in jsonData.classes do
			local thisOutput = ""
			local inherits = classData.inherits
			thisOutput ..= `\n---@class {className}{if inherits then `: {inherits}` else ""}`
			for method, methodData in classData do
				if typeof(methodData) ~= "table" then continue end
				thisOutput ..= `\n---@field {stringifyMethod(method, methodData, className)}`
			end

			thisOutput ..= `\n\n\n`
			classes ..= thisOutput
		end
	end

	--> External Api Data
	local externalApiConstants = "\n\n--> EXTERNAL API"
	for var, type in externalApi.vars do
		externalApiConstants ..= `\n\n---@type {type}\n{var} = nil`
	end

	for funcName, func in externalApi.funcs do
		externalApiConstants ..= `\n\n{stringifyGlobalFunc(funcName, func)}`
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
