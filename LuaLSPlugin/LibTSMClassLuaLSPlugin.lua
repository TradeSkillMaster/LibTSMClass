function OnSetText(uri, text)
    local diffs = {}

    -- Add static class methods to the class
    for startPos, endPos in text:gmatch("function [A-Za-z0-9_]+()%.__static().[A-Za-z0-9_]+%(") do
        diffs[#diffs+1] = {
            start = startPos,
            finish = endPos - 1,
            text = '',
        }
    end

    -- Add private class methods to the class and mark them as private
    for lineStart, modifierStart, modifierEnd in text:gmatch("()function [A-Za-z0-9_]+()%.__private():[A-Za-z0-9_]+%(") do
        diffs[#diffs+1] = {
            start = lineStart,
            finish = lineStart - 1,
            text = '---@private\n',
        }
        diffs[#diffs+1] = {
            start = modifierStart,
            finish = modifierEnd - 1,
            text = '',
        }
    end

    -- Mark private class members which are set in the constructor and denoted by a leading '_' as private
    for funcStart, funcContent in text:gmatch("function [A-Za-z0-9_]+%.?[_a-z]*:__init%([^%)]*%)()(.-)\nend") do
        for lineStart in funcContent:gmatch("()self%._[a-zA-Z0-9_]+ = .-\n") do
            diffs[#diffs+1] = {
                start = funcStart + lineStart - 1,
                finish = funcStart + lineStart - 2,
                text = '---@private\n',
            }
        end
    end

    if #diffs == 0 then
        return nil
    end

    return diffs
end
