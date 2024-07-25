#!/bin/bash

_current_status=$(playerctl status)
case $_current_status in
    "Playing")
        playerctl pause
        ;;
    "Paused")
        playerctl play
        ;;
    *)
        ;;
esac
