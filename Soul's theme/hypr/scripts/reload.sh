#!/bin/bash
killall waybar
swaync-client -rs
hyprctl reload
swaybg -i ~/Pictures/Wallpapers/active/active.jpg -m fill &
waybar &
