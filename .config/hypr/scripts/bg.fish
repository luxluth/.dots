#!/bin/env fish

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if pgrep -f swww-daemon >/dev/null
    if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
        set image "$HOME/Pictures/walls/wallhaven-gwp3j7.png"
        swww img $image --transition-type none
    else
        set image "$HOME/Pictures/walls/wallhaven-2kpgzm.jpg"
        swww img $image --transition-type none
    end
end
