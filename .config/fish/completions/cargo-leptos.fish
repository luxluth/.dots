# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_cargo_leptos_global_optspecs
	string join \n manifest-path= log= h/help V/version
end

function __fish_cargo_leptos_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_cargo_leptos_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_cargo_leptos_using_subcommand
	set -l cmd (__fish_cargo_leptos_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -l manifest-path -d 'Path to Cargo.toml' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -l log -d 'Output logs from dependencies (multiple --log accepted)' -r -f -a "wasm\t'WASM build (wasm, wasm-opt, walrus)'
server\t'Internal reload and csr server (hyper, axum)'"
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -s V -l version -d 'Print version'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "build" -d 'Build the server (feature ssr) and the client (wasm with feature hydrate)'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "test" -d 'Run the cargo tests for app, client and server'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "end-to-end" -d 'Start the server and end-2-end tests'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "serve" -d 'Serve. Defaults to hydrate mode'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "watch" -d 'Serve and automatically reload when files change'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "new" -d 'Start a wizard for creating a new project (using cargo-generate)'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "completions" -d 'Generate shell for `cargo-leptos`'
complete -c cargo-leptos -n "__fish_cargo_leptos_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s p -l project -d 'Which project to use, from a list of projects defined in a workspace' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l features -d 'The features to use when compiling all targets' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l lib-features -d 'The features to use when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l lib-cargo-args -d 'The cargo flags to pass to cargo when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l bin-features -d 'The features to use when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l bin-cargo-args -d 'The cargo flags to pass to cargo when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l js-minify -d 'Minify javascript assets with swc. Applies to release builds only' -r -f -a "true\t''
false\t''"
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s r -l release -d 'Build artifacts in release mode, with optimizations'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s P -l precompress -d 'Precompress static assets with gzip and brotli. Applies to release builds only'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l hot-reload -d 'Turn on partial hot-reloading. Requires rust nightly [beta]'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l wasm-debug -d 'Include debug information in Wasm output. Includes source maps and DWARF debug info'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s v -d 'Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s c -l clear -d 'Clear the terminal before rebuilding'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l split -d 'Split WASM binary based on #[lazy] macros'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l frontend-only -d 'Only build the frontend'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -l server-only -d 'Only build the server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand build" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s p -l project -d 'Which project to use, from a list of projects defined in a workspace' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l features -d 'The features to use when compiling all targets' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l lib-features -d 'The features to use when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l lib-cargo-args -d 'The cargo flags to pass to cargo when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l bin-features -d 'The features to use when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l bin-cargo-args -d 'The cargo flags to pass to cargo when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l js-minify -d 'Minify javascript assets with swc. Applies to release builds only' -r -f -a "true\t''
false\t''"
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s r -l release -d 'Build artifacts in release mode, with optimizations'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s P -l precompress -d 'Precompress static assets with gzip and brotli. Applies to release builds only'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l hot-reload -d 'Turn on partial hot-reloading. Requires rust nightly [beta]'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l wasm-debug -d 'Include debug information in Wasm output. Includes source maps and DWARF debug info'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s v -d 'Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s c -l clear -d 'Clear the terminal before rebuilding'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l split -d 'Split WASM binary based on #[lazy] macros'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l frontend-only -d 'Only build the frontend'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l server-only -d 'Only build the server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -l no-run -d 'Do not run the tests, only build them'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand test" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s p -l project -d 'Which project to use, from a list of projects defined in a workspace' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l features -d 'The features to use when compiling all targets' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l lib-features -d 'The features to use when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l lib-cargo-args -d 'The cargo flags to pass to cargo when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l bin-features -d 'The features to use when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l bin-cargo-args -d 'The cargo flags to pass to cargo when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l js-minify -d 'Minify javascript assets with swc. Applies to release builds only' -r -f -a "true\t''
false\t''"
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s r -l release -d 'Build artifacts in release mode, with optimizations'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s P -l precompress -d 'Precompress static assets with gzip and brotli. Applies to release builds only'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l hot-reload -d 'Turn on partial hot-reloading. Requires rust nightly [beta]'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l wasm-debug -d 'Include debug information in Wasm output. Includes source maps and DWARF debug info'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s v -d 'Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s c -l clear -d 'Clear the terminal before rebuilding'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l split -d 'Split WASM binary based on #[lazy] macros'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l frontend-only -d 'Only build the frontend'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -l server-only -d 'Only build the server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand end-to-end" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s p -l project -d 'Which project to use, from a list of projects defined in a workspace' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l features -d 'The features to use when compiling all targets' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l lib-features -d 'The features to use when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l lib-cargo-args -d 'The cargo flags to pass to cargo when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l bin-features -d 'The features to use when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l bin-cargo-args -d 'The cargo flags to pass to cargo when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l js-minify -d 'Minify javascript assets with swc. Applies to release builds only' -r -f -a "true\t''
false\t''"
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s r -l release -d 'Build artifacts in release mode, with optimizations'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s P -l precompress -d 'Precompress static assets with gzip and brotli. Applies to release builds only'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l hot-reload -d 'Turn on partial hot-reloading. Requires rust nightly [beta]'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l wasm-debug -d 'Include debug information in Wasm output. Includes source maps and DWARF debug info'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s v -d 'Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s c -l clear -d 'Clear the terminal before rebuilding'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l split -d 'Split WASM binary based on #[lazy] macros'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l frontend-only -d 'Only build the frontend'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -l server-only -d 'Only build the server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand serve" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s p -l project -d 'Which project to use, from a list of projects defined in a workspace' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l features -d 'The features to use when compiling all targets' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l lib-features -d 'The features to use when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l lib-cargo-args -d 'The cargo flags to pass to cargo when compiling the lib target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l bin-features -d 'The features to use when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l bin-cargo-args -d 'The cargo flags to pass to cargo when compiling the bin target' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l js-minify -d 'Minify javascript assets with swc. Applies to release builds only' -r -f -a "true\t''
false\t''"
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s r -l release -d 'Build artifacts in release mode, with optimizations'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s P -l precompress -d 'Precompress static assets with gzip and brotli. Applies to release builds only'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l hot-reload -d 'Turn on partial hot-reloading. Requires rust nightly [beta]'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l wasm-debug -d 'Include debug information in Wasm output. Includes source maps and DWARF debug info'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s v -d 'Verbosity (none: info, errors & warnings, -v: verbose, -vv: very verbose)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s c -l clear -d 'Clear the terminal before rebuilding'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l split -d 'Split WASM binary based on #[lazy] macros'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l frontend-only -d 'Only build the frontend'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -l server-only -d 'Only build the server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand watch" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s g -l git -d 'Git repository to clone template from. Can be a full URL (like `https://github.com/leptos-rs/start-actix`), or a shortcut for one of our built-in templates. Recommended shortcuts are:' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s b -l branch -d 'Branch to use when installing from git' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s t -l tag -d 'Tag to use when installing from git' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s p -l path -d 'Local path to copy the template from. Can not be specified together with --git' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s n -l name -d 'Directory to create / project name; if the name isn\'t in kebab-case, it will be converted to kebab-case unless `--force` is given' -r
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s f -l force -d 'Don\'t convert the project name to kebab-case before creating the directory. Note that cargo generate won\'t overwrite an existing directory, even if `--force` is given'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s v -l verbose -d 'Enables more verbose output'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -l init -d 'Generate the template directly into the current dir. No subfolder will be created and no vcs is initialized'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand new" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand completions" -s h -l help -d 'Print help'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "build" -d 'Build the server (feature ssr) and the client (wasm with feature hydrate)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "test" -d 'Run the cargo tests for app, client and server'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "end-to-end" -d 'Start the server and end-2-end tests'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "serve" -d 'Serve. Defaults to hydrate mode'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "watch" -d 'Serve and automatically reload when files change'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "new" -d 'Start a wizard for creating a new project (using cargo-generate)'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "completions" -d 'Generate shell for `cargo-leptos`'
complete -c cargo-leptos -n "__fish_cargo_leptos_using_subcommand help; and not __fish_seen_subcommand_from build test end-to-end serve watch new completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
