# Mod Logger

## Description

Mod for [Luanti] that wraps around the core logger. It adds extra functions &amp; standardized
logging output messages.

## Usage

Adds a single global function `register_mod_logger`:

```
register_mod_logger([mod_table])
- mod_table: Table to which logging functions will be added. If omitted, a new table will be created
    & returned.
- return value: `mod_table` or new table with logging functions.
```

Once registered, the `mod_table` will include the following functions:

Functions:
- log(lvl, msg)
- log(msg)
- info(msg)
- action(msg)
- warn(msg)
- error(msg)
- debug(msg)

Parameters:
- lvl: (optional) Logging level. Can be one of "error", "warn", "action", "info", or "debug". If its
  value is `nil` the standard message logging level will be used (same as `log(msg)`). "warning" is
  alias of "warn".
- msg: Logging message text.

Logging verbosity can be set with the `mod_log_level` setting. Logging levels, other than `debug`,
also abide by level of core Luanti logger.

### Examples

Using as hard dependency:

```lua
my_mod = {}
register_mod_logger(my_mod)
```

Using as soft dependency:

```lua
my_mod = {
    -- only need to add functions that will be used
    log = function(lvl, msg) end,
    info = function(msg) end,
    action = function(msg) end,
    warn = function(msg) end,
    error = function(msg) end,
    debug = function(msg) end
}
if core.global_exists("register_mod_logger") then
    register_mod_logger(my_mod)
end
```

Calling logging functions:

```lua
-- outputs "[<mod_name>] Hello my_mod!" to Luanti logging console
-- same as `my_mod.log("Hello my_mod!")` or `my_mod.log(nil, "Hello my_mod!)`
my_mod.info("Hello my_mod!")

-- outputs "DEBUG[<mod_name>] Hello my_mod!" to Luanti logging console
-- same as `my_mod.log("debug", "Hello my_mod!")`
my_mod.debug("Hello my_mod!")
```

Creating a local logger:

```lua
local my_logger = register_mod_logger()
my_logger.info("Hello my_mod!")
```

## Links

- Git Repo Mirros:
    - [Codeberg](https://codeberg.org/AntumLuanti/mod-mod_logger)
    - [GitHub](https://github.com/AntumMT/mod-mod_logger)
    - [GitLab](https://gitlab.com/AntumMT/mod-mod_logger)
- [Changelog](changelog.txt)

## TODO


[Luanti]: https://www.luanti.org/
