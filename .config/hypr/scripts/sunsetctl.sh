#! /bin/bash

silent=false
fifo=/tmp/sunset-monitor

# wlsunset is an util that changes the color temperature of the screen
stop() {
	if [ "$silent" = false ]; then
		notify-send "󰹏 Night shift disabled" -h string:x-dunst-stack-tag:notifysun
	fi
	killall wlsunset 2>/dev/null >/dev/null
	report_status_to_fifo
}

restart() {
	killall wlsunset 2>/dev/null >/dev/null

	if [ "$silent" = false ]; then
		notify-send "󰛨 Night shift enabled" -h string:x-dunst-stack-tag:notifysun
	fi

	wlsunset &

	report_status_to_fifo
}

get_state() {
	if pgrep wlsunset >/dev/null; then
		echo "ON"
	else
		echo "OFF"
	fi
}

startup() {
	date=$(date +%H)
	if [[ $date -ge 15 || $date -le 10 ]]; then
		restart
	else
		stop
	fi
}

report_status() {
	if pgrep wlsunset >/dev/null; then
		echo '{"percentage": 100, "tooltip": "Redshift is ON"}'
	else
		echo '{"percentage": 0, "tooltip": "Redshift is OFF"}'
	fi
}

report_status_to_fifo() {
	# only write to the FIFO if someone is listening
	if [[ -p $fifo ]]; then
		report_status >$fifo
	fi
}

shutdown_monitor() {
	kill -s SIGTERM $! 2>/dev/null
	[[ -p $fifo ]] && rm $fifo
	echo && exit 0
}

monitor() {
	report_status
	[[ ! -p $fifo ]] && mkfifo $fifo
	trap shutdown_monitor SIGINT
	while true; do
		cat $fifo
	done
}

case "$2" in
--silent)
	silent=true
	;;
esac

case "$1" in
login)
	startup
	;;
start)
	restart
	;;
state)
	get_state
	;;
stop)
	stop
	;;
toggle)
	if pgrep wlsunset >/dev/null; then
		stop
	else
		restart
	fi
	;;
status)
	report_status
	;;
monitor)
	monitor
	;;
*)
	echo "Usage: $0 {login|start|stop|toggle|status|monitor|state} [--silent]"
	exit 1
	;;
esac
