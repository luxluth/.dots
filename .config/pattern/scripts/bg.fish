#!/bin/env fish

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
    # light mode
    set image "$HOME/Pictures/walls/wallhaven-rqjmpj.jpg"
    matugen image $image --source-color-index 0 -m light
    dconf write /org/gnome/desktop/background/picture-uri "'file://$image'"
else
    # dark mode
    set image "$HOME/Pictures/walls/wallhaven-og28j9.png"
    matugen image $image --source-color-index 0 -m dark
    dconf write /org/gnome/desktop/background/picture-uri-dark "'file://$image'"
end

# ~/.config/pattern/scripts/nvim.fish
