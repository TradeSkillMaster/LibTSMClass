local Plugin = {}

local function AddDiff(diffs, startPos, endPos, text)
	if not text then
		return diffs
	end
	diffs = diffs or {}
	table.insert(diffs, {
		start = startPos,
		finish = (endPos or startPos) - 1,
		text = text,
	})
	return diffs
end

local function GetClassInitArgs(className, text, lines)
	if not text then
		return nil
	end
	local docText, argsText = nil, nil
	if lines then
		for i, line in ipairs(lines) do
			argsText = line:match("^function "..className.."%.?_?_?[a-z]*:__init%((.-)%)")
			if argsText then
				local docsStartLine = nil
				for j = i - 1, 1, -1 do
					if not lines[j]:match("^%-%-%-") then
						docsStartLine = j + 1
						break
					end
				end
				if not docsStartLine then
					return nil
				end
				docText = table.concat(lines, "\n", docsStartLine, i - 1)
				break
			end
		end
	else
		docText, argsText = text:match("\r?\n\r?\n(%-%-%-.-)\r?\nfunction "..className.."%.?_?_?[a-z]*:__init%((.-)%)")
	end
	if not docText then
		return nil
	end
	docText = docText.."\n"
	local args = {}
	for arg in argsText:gmatch("[%a%.]+") do
		local argType = docText:match("@param "..arg.." ([a-zA-Z<>,]+)%s")
		if not argType then
			argType = docText:match("@param "..arg.." (fun%(.-%))%s")
		end
		if not argType then
			argType = docText:match("@param "..arg.." (fun%(.-%): %a+%??)%s")
		end
		if not argType then
			argType = docText:match("@param "..arg.." (fun%(.-%): %a+%??, %a+%??)%s")
		end
		if not argType then
			return nil
		end
		table.insert(args, arg..": "..argType)
	end
	return table.concat(args, ", ")
end

function Plugin.DefineClassHelper(className, parentClassName, text, fileLines)
	local lines = {}
	if parentClassName then
		table.insert(lines, "---@class "..className..": "..parentClassName)
		table.insert(lines, "---@field __super "..parentClassName)
	else
		table.insert(lines, "---@class "..className..": Class")
	end
	table.insert(lines, "---@field __class "..className)
	table.insert(lines, "---@field __name string")
	table.insert(lines, "---@field private __closure fun(self, name: string): function")
	table.insert(lines, "---@field __isa fun(self, class: Class): boolean")
	local initArgs = GetClassInitArgs(className, text, fileLines) or "..."
	table.insert(lines, "---@overload fun("..initArgs.."): "..className)
	return table.concat(lines, "\n").."\n"
end

function Plugin.ProcessFileLines(lines, lineStartPos)
	local diffs = nil
	for i, line in ipairs(lines) do
		local lineStart = lineStartPos[i]

		-- Look for function definitions
		local modifierStart, modifier, modifierEnd, modifierColonOrDot = line:match("^function [A-Za-z0-9_]+()%.__([a-z]+)()([:%.])[A-Za-z0-9_]+%(")
		if modifier then
			modifierStart = modifierStart + lineStart - 1
			modifierEnd = modifierEnd + lineStart - 1
			if modifier == "abstract" then
				modifier = "protected"
			end
			if modifier == "static" and modifierColonOrDot == "." then
				-- Add static class methods to the class
				diffs = AddDiff(diffs, modifierStart, modifierEnd, "")
			elseif modifier == "private" or modifier == "protected" then
				diffs = AddDiff(diffs, lineStart, nil, "---@"..modifier.."\n")
				diffs = AddDiff(diffs, modifierStart, modifierEnd, "")
			end
		end

		-- Look for static variable assignment
		local staticStartPos, staticEndPos = line:match("[A-Za-z0-9_]+()%.__static()%.[A-Za-z0-9_]+ = ")
		if staticStartPos then
			staticStartPos = staticStartPos + lineStart - 1
			staticEndPos = staticEndPos + lineStart - 1
			diffs = AddDiff(diffs, staticStartPos, staticEndPos, "")
		end

		-- Mark class members which are set in the constructor and denoted by a leading "_" as protected
		if line:match("^function [A-Za-z0-9_]+%.?[_a-z]*[:%.]__init%([^%)]*%)()(.-)") then
			for j = i + 1, #lines do
				local line2 = lines[j]
				if line2 == "end" then
					break
				end
				local startPos = line2:match("()self%._[a-zA-Z0-9_]+%s*=")
				if startPos then
					startPos = startPos + lineStartPos[j] - 1
					diffs = AddDiff(diffs, startPos, nil, "---@protected\n")
				end
			end
		end

		-- Define classes for LibTSMClass.DefineClass("<CLASS_NAME>", ...) calls
		local defineClassName, defineExtraArgs = line:match("^local [A-Za-z0-9_]+ = LibTSMClass%.DefineClass%(\"([^\"]+)\"(.-)%)")
		if defineClassName then
			local parentClassName = defineExtraArgs:match("^, (%a+)$") or defineExtraArgs:match("^, (%a+), ")
			diffs = AddDiff(diffs, lineStart, nil, Plugin.DefineClassHelper(defineClassName, parentClassName))
		end
	end
	return diffs
end

function Plugin.OnSetText(uri, text)
	-- Split the file into lines for easier parsing
	local lines, lineStartPos = {}, {}
	for startPos, str in text:gmatch("()(.-)\r?\n") do
		table.insert(lines, str)
		table.insert(lineStartPos, startPos)
	end
	return Plugin.ProcessFileLines(lines, lineStartPos)
end

return Plugin
