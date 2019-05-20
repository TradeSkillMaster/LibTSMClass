-- WoW environment setup

-- Date and Time
date = os.date
time = os.time

-- File Functions
loadstring = loadstring or load

-- Math Functions
floor = math.floor
ceil = math.ceil
abs = math.abs
min = math.min
max = math.max
random = math.random

-- Table Functions
CopyTable = function(t)
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = CopyTable(v)
		else
			copy[k] = v
		end
	end
	return copy
end
wipe = function(t)
	local toRemove = {}
	for k in pairs(t) do
		toRemove[k] = true
	end
	for k in pairs(toRemove) do
      t[k] = nil
    end
end
tContains = function(t, v)
	local i = 1
	while t[i] do
		if t[i] == v then
			return 1
		end
		i = i + 1
	end
	return nil
end
newproxy = function()
    local table = {}
    local metatable = {}
    setmetatable(table, metatable)
    return table
end
tinsert = table.insert
tremove = table.remove
sort = table.sort
unpack = unpack or table.unpack

-- String Functions
strjoin = function(sep, ...)
	local result = table.concat({...}, sep)
	return #result > 0 and result or nil
end
strtrim = function (s)
	return s:gsub("^%s*(.-)%s*$", "%1")
end
strfind = string.find
strsub = string.sub
strmatch = string.match
format = string.format
strbyte = string.byte
strchar = string.char
gsub = string.gsub
gmatch = string.gmatch
strlower = string.lower
function string.split(delim, text)
    -- returns an array of fields based on text and delimiter (one character only)
    local result = {}
    local magic = "().%+-*?[]^$"

    if delim == nil then
        delim = "%s"
    elseif string.find(delim, magic, 1, true) then
        -- escape magic
        delim = "%"..delim
    end

    local pattern = "[^"..delim.."]+"
    for w in string.gmatch(text, pattern) do
        table.insert(result, w)
    end
    return unpack(result)
end
strsplit = string.split
function tostringall(...)
	local result = {}
	for i = 1, select("#", ...) do
		result[i] = tostring(select(i, ...))
	end
	return unpack(result)
end
strupper = string.upper

-- Constants
COPPER_PER_GOLD = 10000
COPPER_PER_SILVER = 100
LARGE_NUMBER_SEPERATOR = ","
ITEM_QUALITY_COLORS = {}

-- Bit Functions
bit = {
	lshift = function(value, places) return value * 2 ^ places end
}

-- Global Function Stubs

function debugprofilestop()
	return 0
end

function debugstack(thread, start, countTop, countBottom)
	local lines = nil
	if type(thread) == "thread" then
		lines = { ("\n"):split(debug.traceback(thread)) }
	else
		start, countTop, countBottom = thread, start, countTop
		lines = { ("\n"):split(debug.traceback()) }
	end
	local includeLine = {}
	for i = 1, countTop do
		includeLine[start + i] = true
	end
	for i = 1, countBottom do
		local lineNum = #lines - (i - 1)
		if lineNum > 0 then
			includeLine[lineNum] = true
		end
	end
	local result = nil
	for i = 1, #lines do
		if includeLine[i] then
			result = (result and (result .. "\n") or "") .. lines[i]
		end
	end
	return result or ""
end

function GetLocale()
	return "enUS"
end

function geterrorhandler()
	return function (error) print("error: " .. error) end
end
