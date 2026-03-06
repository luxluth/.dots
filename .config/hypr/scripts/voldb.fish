#!/usr/bin/env fish
# voldb.fish — constant dB volume steps for PipeWire (GNOME-like feel)
# Usage: voldb.fish up | voldb.fish down | voldb.fish mute
# Env vars:
#   VOLSTEP_DB  (default: 1.5)  # dB per step
#   VOL_MAX     (default: 1.0)  # cap (set >1.0 to allow >100%)
#   VOL_MUTE_THRESHOLD  (default 0.03) # near-floor linear; below this we mute

set -l sink "@DEFAULT_AUDIO_SINK@"

if test (count $argv) -ne 1
    echo "Usage: (status filename) up|down|mute" >&2
    exit 2
end

set -l dir $argv[1]
if test "$dir" != up -a "$dir" != down -a "$dir" != mute
    echo "Usage: (status filename) up|down|mute" >&2
    exit 2
end

set -l step_db (set -q VOLSTEP_DB; and echo $VOLSTEP_DB; or echo 1.5)
set -l cap (set -q VOL_MAX; and echo $VOL_MAX; or echo 1.0)
set -l floor (set -q VOL_MUTE_THRESHOLD; and echo $VOL_MUTE_THRESHOLD; or echo 0.03)

# Get current volume (linear 0.0..1.0)
set -l cur_line (wpctl get-volume $sink)
set -l cur (string match -r '[0-9]+\.[0-9]+' -- $cur_line | head -n1)
set -l is_muted (string match -rq '\[MUTED\]' -- $cur_line; and echo 1; or echo 0)

if test "$dir" = mute
    wpctl set-mute $sink toggle
    set cur_line (wpctl get-volume $sink)
    set is_muted (string match -rq '\[MUTED\]' -- $cur_line; and echo 1; or echo 0)

    exit 0
end

if test $is_muted -eq 1 -a "$dir" = up
    set -l start (math "min($floor, $cap)")
    wpctl set-mute $sink 0
    wpctl set-volume $sink $start

    exit 0
end

if test -z "$cur"
    echo "Could not parse volume from: $cur_line" >&2
    exit 1
end

set -l sign (test "$dir" = "up"; and echo 1; or echo -1)

# Factor = 10^(±dB/20)
set -l factor (math "exp(ln(10) * ($step_db/20) * $sign)")
set -l new_raw (math "$cur * $factor")

if test "$dir" = down
    # If new wouldn't change (quantized) or fell under floor, just mute
    set -l no_change (test $new_raw = $cur; and echo 1; or echo 0)
    if test $no_change -eq 1 -o $new_raw -le $floor
        wpctl set-mute $sink 1
        exit 0
    end
end

set -l new (math "min( max($new_raw, 0), $cap )")
wpctl set-volume $sink $new
