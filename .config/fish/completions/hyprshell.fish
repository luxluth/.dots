# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_hyprshell_global_optspecs
	string join \n v q/quiet c/config-file= s/css-file= data-dir= cache-dir= system-data-dir= h/help V/version
end

function __fish_hyprshell_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_hyprshell_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_hyprshell_using_subcommand
	set -l cmd (__fish_hyprshell_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c hyprshell -n "__fish_hyprshell_needs_command" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_needs_command" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_needs_command" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_needs_command" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_needs_command" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_needs_command" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -s V -l version -d 'Print version'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "run" -d 'Run the hyprshell daemon'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "config" -d 'Generate or check the config file'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "debug" -d 'Debug command to debug finding icons for the GUI, desktop files, etc'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "data" -d 'Show data, like launch history, etc'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "socat" -d 'Send json to the hyprshell socket'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "completions" -d 'Generate completions for shells'
complete -c hyprshell -n "__fish_hyprshell_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand run" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -f -a "generate" -d 'Generate a default config file (just opens GUI editor)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -f -a "edit" -d 'Edit the config file with a GUI'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -f -a "check" -d 'Check the config file for errors'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -f -a "explain" -d 'Explain how to use the program based on the config'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and not __fish_seen_subcommand_from generate edit check explain help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from generate" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from edit" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from check" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from explain" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "generate" -d 'Generate a default config file (just opens GUI editor)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "edit" -d 'Edit the config file with a GUI'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "check" -d 'Check the config file for errors'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "explain" -d 'Explain how to use the program based on the config'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "list-icons" -d 'List all icons in the theme'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "list-desktop-files" -d 'List all desktop files'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "check-class" -d 'Search for an icon with a window class'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "search" -d 'simulate search in launcher and display search insights'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "default-applications" -d 'get or set default applications for different mime types'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "info" -d 'print debug info'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and not __fish_seen_subcommand_from list-icons list-desktop-files check-class search default-applications info help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-icons" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from list-desktop-files" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from check-class" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s a -l all -d 'Show all matches, not just x ones like configured in config'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from search" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "get" -d 'Get default app for mimetype'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "set" -d 'Sets a default app for a mimetype (if one already exists, it is replaced)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "add" -d 'Add an association app for mimetype (if one already exists, this one is placed before)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "list" -d 'List default apps for all mimetypes'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "check" -d 'Check if all entries in all mimetype files point to valid desktop files'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from default-applications" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from info" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "list-icons" -d 'List all icons in the theme'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "list-desktop-files" -d 'List all desktop files'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "check-class" -d 'Search for an icon with a window class'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "search" -d 'simulate search in launcher and display search insights'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "default-applications" -d 'get or set default applications for different mime types'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "info" -d 'print debug info'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand debug; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -f -a "launch-history" -d 'Show the history of launched applications'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and not __fish_seen_subcommand_from launch-history help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from launch-history" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from help" -f -a "launch-history" -d 'Show the history of launched applications'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand data; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand socat" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s p -l base-path -d 'BASE Path for completion without filename Bash Default: `/usr/share/bash-completion/completions` Fish Default: `/usr/share/fish/vendor_completions.d` Zsh Default: `/usr/share/zsh/site-functions`' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s c -l config-file -d 'Path to config [default: `$XDG_CONFIG_HOME/hyprshell/config.ron`], allowed file types: ron, toml, json5' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s s -l css-file -d 'Path to css [default: `$XDG_CONFIG_HOME/hyprshell/styles.css`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -l data-dir -d 'Path to data directory [default: `$XDG_DATA_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -l cache-dir -d 'Path to cache directory [default: `$XDG_CACHE_HOME/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -l system-data-dir -d 'Path to system data directory [default: `/usr/share/hyprshell`]' -r -F
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s d -l delete -d 'Delete the generated completion files'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s v -d 'Increase the verbosity level (-v: debug, -vv: trace)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s q -l quiet -d 'Turn off all output'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand completions" -s h -l help -d 'Print help'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "run" -d 'Run the hyprshell daemon'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "config" -d 'Generate or check the config file'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "debug" -d 'Debug command to debug finding icons for the GUI, desktop files, etc'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "data" -d 'Show data, like launch history, etc'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "socat" -d 'Send json to the hyprshell socket'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "completions" -d 'Generate completions for shells'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and not __fish_seen_subcommand_from run config debug data socat completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "generate" -d 'Generate a default config file (just opens GUI editor)'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "edit" -d 'Edit the config file with a GUI'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "check" -d 'Check the config file for errors'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "explain" -d 'Explain how to use the program based on the config'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "list-icons" -d 'List all icons in the theme'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "list-desktop-files" -d 'List all desktop files'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "check-class" -d 'Search for an icon with a window class'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "search" -d 'simulate search in launcher and display search insights'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "default-applications" -d 'get or set default applications for different mime types'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from debug" -f -a "info" -d 'print debug info'
complete -c hyprshell -n "__fish_hyprshell_using_subcommand help; and __fish_seen_subcommand_from data" -f -a "launch-history" -d 'Show the history of launched applications'
