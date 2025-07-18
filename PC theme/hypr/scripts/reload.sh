#!/bin/bash
hyprctl reload
killall waybar
swaync-client -rs
swaybg -i ~/Pictures/Wallpapers/active/active.jpg -m fill &
waybar &
