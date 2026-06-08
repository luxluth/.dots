#!/usr/bin/fish

set output (wpctl get-volume @DEFAULT_AUDIO_SINK@)

set vol (string match -r 'Volume: ([0-9.]+)' -- $output)[2]
set vol_percent (math "round($vol * 100)")

set muted_state NOTMUTED

if string match -q "*[MUTED]*" $output
    set muted_state MUTED
end

if test -z $argv[1]
    echo "VOLUME@$vol_percent" | socat UNIX-CONNECT:/tmp/hd STDIN
else
    if [ $argv[1] = mute ]
        echo "VOLUME@$muted_state" | socat UNIX-CONNECT:/tmp/hd STDIN
    end
end
