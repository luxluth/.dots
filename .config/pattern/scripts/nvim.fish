#!/usr/bin/env fish

set DARK_SCHEME bamboo_muted
set LIGHT_SCHEME alabaster

function update_nvim -a mode colorscheme

    set -l runtime_dir $XDG_RUNTIME_DIR
    if test -z "$runtime_dir"
        set runtime_dir "/run/user/"(id -u)
    end

    for socket in $runtime_dir/nvim.*
        if test -S "$socket"
            nvim --server "$socket" --remote-send "<C-\><C-n>:set background=$mode | colorscheme $colorscheme<CR>" >/dev/null 2>&1
        end
    end
end

set CURRENT_SETTING (gsettings get org.gnome.desktop.interface color-scheme)

if string match -q "*dark*" "$CURRENT_SETTING"
    update_nvim dark "$DARK_SCHEME"
else
    update_nvim light "$LIGHT_SCHEME"
end

gsettings monitor org.gnome.desktop.interface color-scheme | while read -l line
    if string match -q "*dark*" "$line"
        update_nvim dark "$DARK_SCHEME"
    else
        update_nvim light "$LIGHT_SCHEME"
    end
end
