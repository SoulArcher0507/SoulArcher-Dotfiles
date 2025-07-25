#!/bin/bash

if [[ "$1" == "status" ]]; then
    sleep 1
    if pgrep -x hypridle >/dev/null; then
        echo '{"text": "RUNNING", "class": "active", "tooltip": "Screen locking active\nLeft: Deactivate"}'
    else
        echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "Screen locking deactivated\nLeft: Activate"}'
    fi
fi
if [[ "$1" == "toggle" ]]; then
    if pgrep -x hypridle >/dev/null; then
        killall hypridle
        $0 "status"
    else
        hypridle &
        $0 "status"
    fi
fi
