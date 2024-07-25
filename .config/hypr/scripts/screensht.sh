#!/bin/bash

set -o pipefail

# Set the directories
_SCREENSHOT_DIR="$HOME/Pictures/Captures d’écran"
_LOG_FILE_="$HOME/.screensht.log"
_target_file_="$_SCREENSHOT_DIR/$(date +%Y-%m-%d-%H%M%S).png"

function summary() {
	_runtime_job_=$(($2 - $1))
	hours=$((_runtime_job_ / 3600))
	minutes=$(((_runtime_job_ % 3600) / 60))
	seconds=$(((_runtime_job_ % 3600) % 60))

	if [[ $3 != "failed" ]]; then
		wl-copy <$_target_file_
		echo "$_target_file_" >>$_LOG_FILE_ 2>&1

		message="${_notif_message_} Runtime: $hours hours, $minutes minutes, $seconds seconds"
		ACTION=$(dunstify -i "$_target_file_" -t 10000 "Screenshot Tool" "$message" -a "Screenshot Tool" \
			--action="default,Open")
		if [[ $ACTION = "default" ]]; then
			xdg-open "$_target_file_" 2>&1
		fi
	else
		message="Screenshot failed! Runtime: $hours hours, $minutes minutes, $seconds seconds"
		dunstify -i "$_target_file_" -t 10000 "Screenshot Tool" "$message" -a "Screenshot Tool"
	fi
}

function main() {
	_start_job_=$(date +%s)

	_screenshot_command_="$1"
	_notif_message_="$2"

	$_screenshot_command_ "$_target_file_"

	_end_job_=$(date +%s)
	summary $_start_job_ $_end_job_
}

# Check the args passed
if [ -z "$1" ] || ([ "$1" != 'full' ] && [ "$1" != 'area' ]); then
	echo "
	Requires an argument:
	area 	- Area screenshot
	full 	- Fullscreen screenshot
	Example:
	./screensht area
	./screensht full
	"
elif [ "$1" = 'full' ]; then
	msg="Full screenshot saved and copied to clipboard!"
	main 'grimblast copysave output' "${msg}"
elif [ "$1" = 'area' ]; then
	msg='Area screenshot saved and copied to clipboard!'
	main 'grimblast copysave area' "${msg}"
fi
