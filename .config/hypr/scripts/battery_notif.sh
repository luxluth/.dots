#!/bin/bash

prev_bat=$(acpi -b | grep -P -o '[0-9]+(?=%)')

while true; do
	curr_bat=$(acpi -b | grep -P -o '[0-9]+(?=%)')
	if [[ $curr_bat -eq 100 && $prev_bat -lt 100 ]]; then
		notify-send "󱐋 Fully charged" "Level: ${curr_bat}%"
	elif [[ $curr_bat -le 20 && $prev_bat -gt 20 ]]; then
		notify-send --urgency=CRITICAL "  Battery Low" "Level: ${curr_bat}%"
	elif [[ $curr_bat -le 10 && $prev_bat -gt 10 ]]; then
		notify-send --urgency=CRITICAL "  Battery Low" "Level: ${curr_bat}%"
	fi
	prev_bat=$curr_bat
	sleep 10
done
