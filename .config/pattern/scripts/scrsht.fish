#!/usr/bin/env fish

switch $argv[1]
    case edit
        HYPRSHOT_EDITOR=1 qs -c ~/.config/quickshell/HyprQuickFrame/ -n
    case '*'
        qs -c ~/.config/quickshell/HyprQuickFrame/ -n
end
