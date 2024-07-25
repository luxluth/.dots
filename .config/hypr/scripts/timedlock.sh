#/bin/sh

if [ -f "/usr/bin/swayidle" ]; then
    # after 5 minutes of inactivity the screen will lock and after 6 minutes the screen will turn off (DPMS)
    swayidle -w timeout 300 'swaylock -f' timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on'
else
    notify-send "swayidle is not installed."
fi;

