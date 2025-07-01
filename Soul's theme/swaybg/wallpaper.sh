#!/bin/bash

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
WALLPAPER_PATH="$(ls $WALLPAPER_DIR/* | while read imageFile; do echo -en "$imageFile\0icon\x1f$WALLPAPER_DIR/$imageFile\n"; | rofi -no-config -theme fulscreen-preview.rasi -dmenu)"
PAPER="${WALLPAPER_DIR}/${WALLPAPER_PATH}"


if [ -z $WALLPAPER_PATH ]; then
    exit 1
fi

cp $PAPER "${WALLPAPER_DIR}/active/active.jpg"

pkill -x swaybg
swaymsg exec "swaybg -i \"$PAPER\" -m fill &"

magick "$WALLPAPER_DIR/active/active.jpg" -resize 75% "$WALLPAPER_DIR/active/active_blur.jpg"
magick "$WALLPAPER_DIR/active/active_blur.jpg" -blur "50x30" "$WALLPAPER_DIR/active/active_blur.jpg"
magick "$WALLPAPER_DIR/active/active.jpg" -gravity Center -extent 1:1 "$WALLPAPER_DIR/active/active_square.jpg"

$HOME/.config/wal/colors.sh "$PAPER"

swaync-client -rs

killall waybar
sway reload
