#!/bin/bash
hyprctl reload
if command -v swww >/dev/null 2>&1; then
  if ! swww query >/dev/null 2>&1; then
    swww init || true
    sleep 0.05
  fi
fi

swaync-client -rs
#pkill qs
#setsid -f qs -d >/dev/null 2>&1 || nohup qs -d >/dev/null 2>&1 &
