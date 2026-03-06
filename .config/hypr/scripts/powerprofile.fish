#!/bin/env fish

function _usage
    echo "Usage: powerprofile.fish <COMMAND> [ARGS]
    COMMAND:
      get                Get the current power profile
      set [PROFILE]      Set the power profile to a certain level
      list               List all power profiles
    PROFILE:
      performance        High performance and energy consumption
      balanced           Normal performance and energy consumption
      power-saver        You want that PC to be alive no matter what
    "
end

if test -z $argv[1]
    _usage
else if string match -q -r -- get $argv[1]
    powerprofilesctl get
else if string match -q -r -- list $argv[1]
    powerprofilesctl
else if string match -q -r -- set $argv[1]
    if test -z $argv[2]
        echo "No profile provided"
        _usage
    else
        powerprofilesctl set $argv[2]
    end
end
