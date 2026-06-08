# Mod Logger

## Description

Mod for [Luanti] that adds standardized mod logging functions.

## Usage

Adds a single global function `register_mod_logger`:

```
register_mod_logger(mod_table)
- mod_table: Table to which logging functions will be added.
```

Once registered, the `mod_table` will include the following functions:

```
Functions:
- log(lvl, msg)
- log(msg)
- info(msg)
- action(msg)
- warn(msg)
- error(msg)
- debug(msg)

Parameters:
- lvl: (optional) Logging level. Can be one of "warn", "info", "action", "error", or "debug". If its
  value is `nil` the standard message logging level will be used (same as `log(msg)`).
- msg: Logging message text.

The `debug` function will only output text when the setting `enable_debug_mods` is set to `true`.
All other functions abide by Luanti logging levels.

Example Lua code:

```lua
my_mod = {}
register_mod_logger(my_mod)

-- outputs "[<mod_name>] Hello my_mod!" to Luanti logging console
my_mod.log("Hello my_mod!")
```

## Links

- Git Repo Mirros:
    - [Codeberg](https://codeberg.org/AntumLuanti/mod-mod_logger)
    - [GitHub](https://github.com/AntumMT/mod-mod_logger)
    - [GitLab](https://gitlab.com/AntumMT/mod-mod_logger)
- [Changelog](changelog.txt)

## TODO

- use log level enum & only show messages if logging level setting is equal or above


[Luanti]: https://www.luanti.org/
