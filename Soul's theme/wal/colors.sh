#!/bin/bash

# === Config ===
#WALLPAPER="$HOME/Pictures/background.png"
WALLPAPER=$1
WAYBAR_CSS="$HOME/.config/waybar/colors.css"
SWAYNC_CSS="$HOME/.config/swaync/colors.css"
ROFI_RASI="$HOME/.config/rofi/colors.rasi"
SWAY="$HOME/.config/sway/colors.conf"


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

#Sway
{
    # variabili
    echo "set \$bg       $background"
    echo "set \$fg       $foreground"
    for i in {0..15}; do
        c=$(jq -r ".colors.color$i" "$HOME/.cache/wal/colors.json")
        echo "set \$color$i $c"
    done

    # esempi di utilizzo (metti queste righe nel tuo config sway o qui se fai include):
    echo ""
    echo "# bordo e barra"
    echo "client.focused          \$color2 \$color0 \$color7"
    echo "client.unfocused        \$color8 \$color0 \$color7"
    echo "client.background       \$bg"
    echo "bar {
      status_command waybar
      colors {
        background \$bg
        statusline \$fg
        separator  \$color7
      }
    }"
} > "$SWAY_COLORS"

$HOME/.config/waybar/scripts/svg-color-switcher.sh $foreground

killall waybar
swaymsg reload
