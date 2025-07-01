#!/bin/bash

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
WALLPAPER_PATH=$(ls $WALLPAPER_DIR | while read A ; do  echo -en "$A\x00icon\x1f$WALLPAPER_DIR/$A\n"; done | rofi -dmenu -p "Enter wallpaper name:")
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
