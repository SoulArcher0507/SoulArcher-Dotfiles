#!/bin/bash

# Carica la definizione dei colori (adatta se hai un file in formato shell)
# Es: in colors.sh hai: export color10=#ff5555, export on_surface=#ffffff, export error=#ff0000, …
tmpfile=$(mktemp)
sed -E \
  's/^\$([A-Za-z0-9_]+) = rgb\(([0-9A-Fa-f]{6})\)/export \1="#\2"/' \
  "$HOME/.config/hypr/colors.conf" > "$tmpfile"
source "$tmpfile"
rm "$tmpfile"

# Comando di lock (swaylock)
lock_cmd="swaylock -f \
  --image \"$HOME/Pictures/Wallpapers/active/active_blur.jpg\" \
  --clock \
  --clock-format=\"%H:%M\" \
  --indicator \
  --indicator-size=200 \
  --indicator-thickness=3 \
  --indicator-radius=40 \
  --inside-color=${fg} \
  --ring-color=${color10} \
  --key-hl-color=${color10} \
  --separator-color=${fg} \
  --verif-color=${color10} \
  --wrong-color=${color9} \
  --text-color=${color1} \
  --fade-in 1.0"

# Avvia swayidle in modalità “-w” (wait for resume)
exec swayidle -w \
  timeout 30    "$lock_cmd"                             \
  resume         "swaymsg 'output * dpms on'"            \
  timeout 30    "swaymsg 'output * dpms off'"           \
  before-sleep   "$lock_cmd && swaymsg 'output * dpms off'"   

# 5 minuti di inattività → lock              300
# al resume, riaccendi i monitor
# dopo altri 5 minuti, DPMS off              600
# prima di sleep → lock + DPMS off
