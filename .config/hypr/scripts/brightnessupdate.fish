#!/usr/bin/fish

set current (brightnessctl get)
set max (brightnessctl max)

set _percent (math "round(($current * 100) / $max)")
