
local mod_logger = {
	modname = core.get_current_modname(),
	log = function() end,
	error = function() end,
	warn = function() end,
	action = function() end,
	info = function() end,
	debug = function() end
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
--  @param lvl
--    Logging level. If its value is `nil` the standard message logging level ("info") is used (same
--    as `log_mod(msg)`). Supported log levels:
--    - "error"
--    - "warn" | "warning"
--    - "action"
--    - "info"
--    - "debug"
--  @param msg
--    Logging message text.
local log_mod = function(mod_name, lvl, msg)
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


--- Adds logging functions to a table.
--
--  Functions added to `logger` table:
--  - `logger.log(lvl, msg)`
--  - `logger.log(msg)`
--  - `logger.warn(msg)`
--  - `logger.error(msg)`
--  - `logger.debug(msg)`
--
--  @param name
--    Logger name that will prefix messages. If omitted, mod name will be used.
--  @param logger
--    Table to which logging functions will be added. If omitted, a new table will be created &
--    returned.
--  @return
--    `logger` or new table with logging functions.
add_mod_logger = function(name, logger)
	if logger == nil then
		if type(name) == "table" then
			logger = name
			name = nil
		else
			logger = {}
		end
	end
	-- mod name is used by default
	name = name ~= nil and name or core.get_current_modname()

	if type(logger) ~= "table" then
		mod_logger.error("invalid parameter `logger` for `register_mod_logger`, must be table")
		return
	elseif type(name) ~= "string" then
		mod_logger.error("invalid parameter `name` for `register_mod_logger`, must be string")
		return
	end

	-- main logging function
	logger.log = function(lvl, msg)
		log_mod(name, lvl, msg)
	end

	-- wrapper for logging info level messages
	logger.info = function(msg)
		log_mod(name, nil, msg)
	end

	-- wrapper for logging action level messages
	logger.action = function(msg)
		log_mod(name, "action", msg)
	end

	-- wrapper for logging warning level messages
	logger.warn = function(msg)
		log_mod(name, "warn", msg)
	end

	-- wrapper for logging error level messages
	logger.error = function(msg)
		log_mod(name, "error", msg)
	end

	-- wrapper for logging debug level message
	logger.debug = function(msg)
		log_mod(name, "debug", msg)
	end

	mod_logger.debug("registered logger '"..name.."'")
	return logger
end

-- backward compat
register_mod_logger = add_mod_logger

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


-- DEBUG:
if logging_level == LogLevel.DEBUG then
	mod_logger.info("testing mod logger functions ...")
	for k, v in pairs(mod_logger) do
		if type(v) == "function" then
			v(k.." message")
		end
	end
end
