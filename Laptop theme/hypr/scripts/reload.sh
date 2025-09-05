#!/bin/bash
hyprctl reload
pkill qs
qs &
swaybg -i ~/Pictures/Wallpapers/active/active.jpg -m fill &
