#!/usr/bin/env sh

tagVol="notifyvol"

function notify_vol
{
	vol=$(pamixer --get-volume | cat)

	sink=$(pamixer --get-default-sink | tail -1 | rev | cut -d '"' -f -2 | rev | sed 's/"//')
	mute=$(pamixer --get-mute | cat)

	if [ "$mute" == true ]; then
		dunstify "󰝟 Muted" -a "$sink" -u low -h string:x-dunst-stack-tag:notifyvol -t 800

	elif [ $vol -ne 0 ]; then
		dunstify -a "$sink" -u low -h string:x-dunst-stack-tag:notifyvol \
			-h int:value:"$vol" "$1 Volume: ${vol}%" -t 800
	else
		dunstify "$1 Volume: ${vol}%" -a "$sink" -u low -h string:x-dunst-stack-tag:notifyvol -t 800
	fi
}

case $1 in
i)
	pamixer -i 5
	notify_vol 󰝝
	;;
d)
	pamixer -d 5
	notify_vol 󰝞
	;;
m)
	pamixer -t
	notify_vol 
	;;
*)
	echo "volumecontrol.sh [action]"
	echo "i -- increase volume [+5]"
	echo "d -- decrease volume [-5]"
	echo "m -- mute [x]"
	;;
esac
