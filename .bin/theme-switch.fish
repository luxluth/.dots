#!/bin/env fish

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    kitten themes --reload-in=all "Gruvbox Dark"
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark
else if string match -q prefer-dark $current_scheme
    gsettings set org.gnome.desktop.interface color-scheme default
    kitten themes --reload-in=all Dawnfox
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
end
