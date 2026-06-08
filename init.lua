
local mod_logger = {
	modname = core.get_current_modname()
}

local LogLevel = {
	SILENT = 0,
	ERROR = 1,
	WARN = 2,
	WARNING = 2,
	ACTION = 3,
	INFO = 4,
	DEBUG = 5
}


--- Checks logging level.
--
--  @param lvl
--    Logging level string.
--  @return
--    Logging level integer or `nil` if invalid level.
local check_level = function(lvl)
	lvl = lvl or "INFO"
	return LogLevel[lvl:upper()]
end


--- Configured logging verbosity level.
local logging_level = check_level(core.settings:get("mod_log_level"))


--- Base logging function.
--
--  @param mod_name
--    Name of logging mod.
--  @param mod_table
--    Table containing logging info.
--  @param lvl
--    Logging level. If its value is `nil` the standard message logging level ("info") is used (same
--    as `log(msg)`). Supported log levels:
--    - "error"
--    - "warn" | "warning"
--    - "action"
--    - "info"
--    - "debug"
--  @param msg
--    Logging message text.
local log = function(mod_name, mod_table, lvl, msg)
	if logging_level < 1 then
		-- logging disabled
		return
	end

	if msg == nil then
		msg = lvl
		lvl = nil
	end

	local message_level = check_level(lvl)
	if message_level == nil then
		mod_logger.warn("Unknown log level: \""..tostring(lvl).."\"")
		return
	elseif logging_level < message_level then
		-- don't show message of higher verbosity
		return
	end

	lvl = lvl and lvl:lower()
	if lvl == "info" then
		-- "info" is default logging level, same as `nil` for core.log
		lvl = nil
	elseif lvl == "warn" then
		-- core logger only recognizes "warning"
		lvl = "warning"
	end

	local prefix = "["..mod_name.."]"
	if lvl ~= nil then
		-- exclude prefixes already added by Luanti engine
		if lvl ~= "action" and lvl ~= "warning" and lvl ~= "error" then
			prefix = lvl:upper()..prefix
		end
	end

	msg = prefix.." "..msg
	if not lvl or lvl == "debug" then
		core.log(msg)
	else
		core.log(lvl, msg)
	end
end


--- Registers logging functions to mod.
--
--  Functions added to `mod_table`:
--  - `mod_table.log(lvl, msg)`
--  - `mod_table.log(msg)`
--  - `mod_table.warn(msg)`
--  - `mod_table.error(msg)`
--  - `mod_table.debug(msg)`
--
--  @param mod_table
--    Table to which logging functions will be added. If omitted, a new table will be created &
--    returned.
--  @return
--    `mod_table` or new table with logging functions.
register_mod_logger = function(mod_table)
	mod_table = mod_table or {}
	local mod_name = core.get_current_modname()

	-- main logging function
	mod_table.log = function(lvl, msg)
		log(mod_name, mod_table, lvl, msg)
	end

	-- wrapper for logging info level messages
	mod_table.info = function(msg)
		log(mod_name, mod_table, nil, msg)
	end

	-- wrapper for logging action level messages
	mod_table.action = function(msg)
		log(mod_name, mod_table, "action", msg)
	end

	-- wrapper for logging warning level messages
	mod_table.warn = function(msg)
		log(mod_name, mod_table, "warn", msg)
	end

	-- wrapper for logging error level messages
	mod_table.error = function(msg)
		log(mod_name, mod_table, "error", msg)
	end

	-- wrapper for logging debug level message
	mod_table.debug = function(msg)
		log(mod_name, mod_table, "debug", msg)
	end

	if mod_logger.debug then
		mod_logger.debug("registered logger for mod '"..mod_name.."'")
	end

	return mod_table
end


-- ensure using valid logging level
if logging_level == nil then
	core.log("warning", "["..mod_logger.modname.."] Invalid value for \"mod_log_level\" setting, defaulting to \"INFO\" ...")
	logging_level = LogLevel.INFO
end
for k, v in pairs(LogLevel) do
	if v == logging_level then
		core.log("action", "["..mod_logger.modname.."] Mod logging level: "..k)
		break
	end
end

-- register logger for this mod
register_mod_logger(mod_logger)
