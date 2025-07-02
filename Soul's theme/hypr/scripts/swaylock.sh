#!/bin/bash

# Carica la definizione dei colori (adatta se hai un file in formato shell)
# Es: in colors.sh hai: export color10=#ff5555, export on_surface=#ffffff, export error=#ff0000, …
source "$HOME/.config/hypr/colors.sh"

# Comando di lock (swaylock)
lock_cmd="swaylock -f \
  --image \"$HOME/Pictures/Wallpapers/active/active_blur.jpg\" \
  --clock \
  --clock-format=\"%H:%M\" \
  --indicator \
  --indicator-size=200 \
  --indicator-thickness=3 \
  --indicator-radius=40 \
  --inside-color=\$fg \
  --ring-color=\$color10 \
  --key-hl-color=\$color10 \
  --separator-color=\$fg \
  --verif-color=\$color10 \
  --wrong-color=\$9 \
  --text-color=\$color1 \
  --fade-in 1.0"

# Avvia swayidle in modalità “-w” (wait for resume)
exec swayidle -w \
  timeout 30    "$lock_cmd"                             \  # 5 minuti di inattività → lock
  resume         "swaymsg 'output * dpms on'"            \  # al resume, riaccendi i monitor
  timeout 600    "swaymsg 'output * dpms off'"           \  # dopo altri 5 minuti, DPMS off
  before-sleep   "$lock_cmd && swaymsg 'output * dpms off'"   # prima di sleep → lock + DPMS off
