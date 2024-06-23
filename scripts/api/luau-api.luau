local function toLuauType(arg, useNil: boolean?): string
	if arg == "array" then
		arg = "{ any }"
	elseif arg == "table" then
		arg = "{ [any]: any }"
	elseif arg == "void" or arg == "" or arg == " " then
		arg = if useNil then "nil" else "()"
	elseif arg == "function" then
		arg = "(...any) -> (...any)"
	elseif arg == "multiple" then
		arg = "...any"
	elseif arg == "The" or arg == "sync" then -- unknown args (wtf is "The")
		arg = "any"
	end

	return arg or "()"
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
					type ..= `{if i > 1 then " | " else ""}{toLuauType(argType)}`
				end
			end
			args ..= ` {argName}: {type},`
		end
	end

	local returns = ""
	if methodData.returns then
		for i, returnType in methodData.returns do
			returns ..= `{if i > 1 then " | " else ""}{toLuauType(returnType, i > 1)}`
		end
	end

	returns = toLuauType(returns)
	returns = if returns:find(",") then `({returns})` else returns
	return `function {methodName}({if class then `self{if args:len() > 2 then ", " else ""}` else ""}{args:sub(2, -2)}): {returns}`
end

return function(jsonData, externalApi, xmlPath)
	local constants = "\n\n--> CONSTANTS"
	do --> Globals
		for constantType, constant in jsonData.global do
			if constantType == "vars" then
				for varName, value in constant do
					constants ..= `\ndeclare {varName}: {value.type}`
				end
			end

			if constantType == "funcs" then
				for funcName, func in constant do
					constants ..= `\ndeclare {stringifyMethod(funcName, func)}`
				end
			end
		end
	end

	local classes = "\n\n--> CLASSES"
	do --> Classes
		local normal = "" -- base class
		local extending = "" -- classes that extend classes
		local extendingAnother = "" -- classes that extend extended classes
		for className, classData in jsonData.classes do
			local thisOutput = ""
			local inherits = classData.inherits
			thisOutput ..= `\ndeclare class {className}{if inherits then ` extends {inherits}` else ""}`
			for method, methodData in classData do
				if typeof(methodData) ~= "table" then continue end
				thisOutput ..= `\n\t{stringifyMethod(method, methodData, className)}`
			end

			thisOutput ..= `\nend`
			if inherits and jsonData.classes[inherits].inherits then
				extendingAnother ..= thisOutput
			elseif inherits then
				extending ..= thisOutput
			else
				normal ..= thisOutput
			end
		end

		classes ..= normal .. extending .. extendingAnother
	end

	--> External Api Data
	local externalApiConstants = "\n\n--> EXTERNAL API"
	for var, type in externalApi.vars do
		externalApiConstants ..= `\ndeclare {var}: {type}`
	end

	for funcName, func in externalApi.funcs do
		externalApiConstants ..= `\ndeclare {stringifyMethod(funcName, func)}`
	end

	--> XML Data
	local xmlData = "\n\n--> XML DATA"
	if xmlPath then
		require("getXML")(xmlPath, true, function(name: string, type: string, headerData: string?)
			if headerData then
				xmlData ..= `\ndeclare {name}: \{ {type} }`
				return
			end
			xmlData ..= `\ndeclare {name}: {type}`
		end)
	end

	return classes .. constants .. externalApiConstants .. xmlData
end
