#!/bin/env fish

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if pgrep -f awww-daemon >/dev/null
    if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
        # light mode
        set image "$HOME/Pictures/walls/wallhaven-xezq13.jpg"
        awww img $image --transition-type fade --transition-fps 60 --transition-duration 0.5
    else
        # dark mode
        set image "$HOME/Pictures/walls/wallhaven-e83pzk.jpg"
        awww img $image --transition-type fade --transition-fps 60 --transition-duration 0.5
    end
end
