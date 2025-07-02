#!/bin/bash

if [[ "$1" == "status" ]]; then
    sleep 1
    if pgrep -x swayidle >/dev/null; then
        echo '{"text": "RUNNING", "class": "active", "tooltip": "Screen locking active\nLeft: Deactivate"}'
    else
        echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "Screen locking deactivated\nLeft: Activate"}'
    fi
fi
if [[ "$1" == "toggle" ]]; then
    if pgrep -x swayidle >/dev/null; then
        pkill -x swayidle
        $0 "status"
    else
        swayidle -w \
            timeout 300 'swaylock -f -c 000000' \
            timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
            before-sleep 'swaylock -f -c 000000'
            $0 "status"
    fi
fi
