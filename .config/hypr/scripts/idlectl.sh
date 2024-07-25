#! /bin/bash

silent=false
fifo=/tmp/idle-monitor

stop() {
	if [ "$silent" = false ]; then
		notify-send "零 Stopping idle management" -h string:x-dunst-stack-tag:notifyidle
	fi
	killall hypridle 2>/dev/null >/dev/null
	report_status_to_fifo
}

restart() {
	killall hypridle 2>/dev/null >/dev/null

	if [ "$silent" = false ]; then
		notify-send "鈴 Starting idle management" -h string:x-dunst-stack-tag:notifyidle
	fi

	hypridle >/dev/null 2>&1 &

	report_status_to_fifo
}

get_state() {
	if pgrep hypridle >/dev/null; then
		echo "ON"
	else
		echo "OFF"
	fi
}

report_status() {
	if pgrep hypridle >/dev/null; then
		echo '{"percentage": 100, "tooltip": "Will go to sleep if left idle", "status": "ON"}'
	else
		echo '{"percentage": 0, "tooltip": "Idle management is OFF", "status": "OFF"}'
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
	if pgrep hypridle >/dev/null; then
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
	echo "Usage: $0 {start|stop|toggle|monitor|state|status} [--silent]"
	exit 1
	;;
esac
