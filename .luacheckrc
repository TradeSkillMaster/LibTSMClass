-- load globals
globals = {
	"LibStub",
	"format",
	"gsub",
	"strfind",
	"strmatch",
	"strrep",
	"strsplit",
	"tinsert",
	"tremove",
	"wipe",
}

-- no max line length
max_line_length = false
-- show warning codes in output
codes = true
-- ignore warnings
ignore = {
	"311", -- pre-setting locals to nil
	"212/self", -- unused self
}
-- only output files with warnings / errors
quiet = 1
-- exclude Tests and Libs folders
exclude_files = { ".luacheckrc", "Tests/**", "LibStub/**", "LuaLSPlugin/**" }
