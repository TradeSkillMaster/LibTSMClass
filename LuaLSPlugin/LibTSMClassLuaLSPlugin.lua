function OnSetText(uri, text)
    local diffs = {}

    -- Look for function definitions
    for lineStart, modifierStart, modifier, modifierEnd, colonOrDot in text:gmatch("()function [A-Za-z0-9_]+()%.__([a-z]+)()([:%.])[A-Za-z0-9_]+%(") do
        if modifier == "abstract" then
            modifier = "protected"
        end
        if modifier == "static" and colonOrDot == "." then
            -- Add static class methods to the class
            diffs[#diffs+1] = {
                start = modifierStart,
                finish = modifierEnd - 1,
                text = "",
            }
        elseif modifier == "private" or modifier == "protected" then
            diffs[#diffs+1] = {
                start = lineStart,
                finish = lineStart - 1,
                text = "---@"..modifier.."\n",
            }
            diffs[#diffs+1] = {
                start = modifierStart,
                finish = modifierEnd - 1,
                text = "",
            }
        end
    end

    -- Look for static function assignment
    for startPos, endPos in text:gmatch("[A-Za-z0-9_]+()%.__static()%.[A-Za-z0-9_]+ = ") do
        diffs[#diffs+1] = {
            start = startPos,
            finish = endPos - 1,
            text = "",
        }
    end

    -- Mark class members which are set in the constructor and denoted by a leading "_" as private
    for funcStart, funcContent in text:gmatch("function [A-Za-z0-9_]+%.?[_a-z]*[:%.]__init%([^%)]*%)()(.-)\nend") do
        for lineStart in funcContent:gmatch("()self%._[a-zA-Z0-9_]+%s*=") do
            diffs[#diffs+1] = {
                start = funcStart + lineStart - 1,
                finish = funcStart + lineStart - 2,
                text = "---@private\n",
            }
        end
    end

    if #diffs == 0 then
        return nil
    end

    return diffs
end
