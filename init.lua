
local mod_logger = {}
local debug_mods = core.settings:get_bool("enable_debug_mods", false)


--- Core logging function.
--
--  @param mod_name
--    Name of logging mod.
--  @param mod_table
--    Table containing logging info.
--  @param lvl
--    Logging level. If its value is `nil` the standard message logging level ("info") is used (same
--    as `log(msg)`). Supported log levels:
--    - "info"
--    - "action"
--    - "warn" | "warning"
--    - "error"
--    - "debug"
--  @param msg
--    Logging message text.
local log = function(mod_name, mod_table, lvl, msg)
	if msg == nil then
		msg = lvl
		lvl = nil
	end
	lvl = lvl and lvl:lower()
	if lvl == "info" then
		-- "info" is default logging level, same as `nil` for core.log
		lvl = nil
	end

	local prefix = "["..mod_name.."]"
	if lvl ~= nil then
		if lvl == "debug" and not debug_mods then
			return
		elseif lvl == "warn" then
			-- core logger only recognizes "warning"
			lvl = "warning"
		end

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
--    Table to which logging functions will be added.
register_mod_logger = function(mod_table)
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
end


-- register logger for this mod
register_mod_logger(mod_logger)

-- debug
if debug_mods then
	mod_logger.info("info log message")
	mod_logger.action("action log message")
	mod_logger.warn("warning log message")
	mod_logger.error("error log message")
	mod_logger.debug("debug log message")
end
