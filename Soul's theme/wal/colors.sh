#!/bin/bash

# === Config ===
#WALLPAPER="$HOME/Pictures/background.png"
WALLPAPER=$1
WAYBAR_CSS="$HOME/.config/waybar/colors.css"
SWAYNC_CSS="$HOME/.config/swaync/colors.css"
WLOGOUT_CSS="$HOME/.config/wlogout/colors.css"
ROFI_RASI="$HOME/.config/rofi/colors.rasi"
HYPR="$HOME/.config/hypr/colors.conf"


# === Generate pywal colors without applying them ===
# To avoid changing the terminal's colors: wal -n -s -t -i "$WALLPAPER"
wal -i "$WALLPAPER"

# === Read colors from pywal ===
WAL_COLORS="$HOME/.cache/wal/colors.json"
if [ ! -f "$WAL_COLORS" ]; then
    echo "Error: $WAL_COLORS not found."
    exit 1
fi

#Waybar + SwayNC
cp $HOME/.cache/wal/colors-waybar.css $WAYBAR_CSS
cp $HOME/.cache/wal/colors-waybar.css $SWAYNC_CSS
cp $HOME/.cache/wal/colors-waybar.css $WLOGOUT_CSS

background=$(jq -r '.special.background' "$WAL_COLORS")
foreground=$(jq -r '.special.foreground' "$WAL_COLORS")

#Rofi
{
    echo "* {"
    echo "bg: $background;"
    echo "fg: $foreground;"

    for i in {0..15}; do
        color=$(jq -r ".colors.color$i" "$WAL_COLORS")
        echo "color$i: $color;"
    done
    echo "}"
} > "$ROFI_RASI"

#Hyprland
{
    echo "\$bg = rgb(${background//#/})"
    echo "\$fg = rgb(${foreground//#/})"

    for i in {0..15}; do
        color=$(jq -r ".colors.color$i" "$WAL_COLORS" | sed 's/#//')
        echo "\$color$i = rgb($color)"
    done
} > "$HYPR"

$HOME/.config/waybar/scripts/svg-color-switcher.sh $foreground

$HOME/.config/hypr/scripts/reload.sh