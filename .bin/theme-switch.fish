#!/bin/env fish

function reload_waybar
    rm ~/.config/waybar/style.css
    ln -s /home/luxluth/.config/waybar/$argv[1].style.css /home/luxluth/.config/waybar/style.css
end

set current_scheme (gsettings get org.gnome.desktop.interface color-scheme | string replace --all "'" "")

if string match -q default $current_scheme; or string match -q prefer-light $current_scheme
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark

else if string match -q prefer-dark $current_scheme
    gsettings set org.gnome.desktop.interface color-scheme default
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3

end

~/.config/hypr/scripts/bg.fish
