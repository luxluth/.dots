#!/usr/bin/env fish

switch $argv[1]
    case region
        grim -l 0 -g $(slurp) -t ppm - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
    case window
        grim -l 0 -g $(hyprctl clients -j | jq -r '(.[] .at + .[] .size) as $dim | "\($dim[0]),\($dim[1]) \($dim[2])x\($dim[3])"' | slurp -d -F "Iosevka Curly Slab") -t ppm - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
end
