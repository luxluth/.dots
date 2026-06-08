#!/bin/env fish

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if pgrep -f awww-daemon >/dev/null
    if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
        # light mode
        set image "$HOME/Pictures/walls/wallhaven-k828y1.png"
        matugen image $image --source-color-index 0
    else
        # dark mode
        set image "$HOME/Pictures/walls/wallhaven-w5l7j7.jpg"
        matugen image $image --source-color-index 0
    end

end
