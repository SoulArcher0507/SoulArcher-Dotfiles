#!/bin/bash
#  _   _                  _     _ _
# | | | |_   _ _ __  _ __(_) __| | | ___
# | |_| | | | | '_ \| '__| |/ _` | |/ _ \
# |  _  | |_| | |_) | |  | | (_| | |  __/
# |_| |_|\__, | .__/|_|  |_|\__,_|_|\___|
#        |___/|_|
#

SERVICE="swayidle"
if [[ "$1" == "status" ]]; then
    sleep 1
    if pgrep -x "$SERVICE" >/dev/null; then
        echo '{"text": "RUNNING", "class": "active", "tooltip": "Screen locking active Left: Deactivate"}'
    else
        echo '{"text": "NOT RUNNING", "class": "notactive", "tooltip": "Screen locking deactivated Left: Activate"}'
    fi
elif [[ "$1" == "toggle" ]]; then
    if pgrep -x "$SERVICE" >/dev/null; then
        killall swayidle
    else
        swayidle -w \
            timeout 300 'swaylock -f -c 000000' \
            timeout 600 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"'
    fi
fi
