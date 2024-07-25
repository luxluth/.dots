#!/usr/bin/env bash

function get_max_brightness {
	brightnessctl max
}

function get_brightness {
	brightnessctl get
}

function ruleofthree {
	# a -> 100%
	# b -> x%
	# x = (b * 100) / a
	a=$1
	b=$2
	echo "$b * 100 / $a" | bc
}

function notify_light {
	max=$(get_max_brightness | cat) # 19200 --> 100%
	light=$(get_brightness | cat)   # 9600 --> 50%

	light=$(ruleofthree $max $light)
	dunstify -a "Brightness" -u low -h string:x-dunst-stack-tag:notifylight \
		-h int:value:"$light" "󰃟 Brightness: ${light}%" -r 91190 -t 800
}

function plus {
	brightnessctl set 5%+
	notify_light
}

function minus {
	max=$(get_max_brightness | cat)
	light=$(get_brightness | cat)
	brightness=$(ruleofthree $max $light)
	if [ $brightness -gt 5 ]; then
		brightnessctl set 5%-
	fi
	notify_light
}

case $1 in
i)
	plus
	;;
d)
	minus
	;;
*)
	echo "brightnesscontrol.sh [action]"
	echo "i -- increase the brightness [+5]"
	echo "d -- decrease the brightness [-5]"
	;;
esac
