#!/usr/bin/env fish

grim -l 0 -g "$(slurp)" -t ppm - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
