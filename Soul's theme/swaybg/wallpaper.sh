#!/bin/bash

WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
FIFO="/tmp/rofi-preview.fifo"

# Prepara la named pipe
[[ -e $FIFO ]] && rm $FIFO
mkfifo $FIFO

# Demone ueberzug: ascolta sulla pipe e mostra l’immagine corrispondente
bash -c '
  exec 3<> '"$FIFO"'
  while read -u 3 line; do
    # rimuove eventiali preview precedenti
    ueberzug layer --parser bash <<-EOF
    [{"action":"remove","identifier":"preview"}]
EOF
    # se c’è un file valido, aggiunge il preview
    if [[ -f "'"$WALLPAPER_DIR"'/$line" ]]; then
      ueberzug layer --parser bash <<-EOF
      [{"action":"add",
        "identifier":"preview",
        "x":700, "y":200,
        "width":400, "height":300,
        "path":"'"$WALLPAPER_DIR"'/$line"}]
EOF
    fi
  done
' &

# Costruisci la lista e lancia rofi
mapfile -t files < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f -printf '%f\n')
selection=$(printf '%s\n' "${files[@]}" \
  | rofi -dmenu -p "Scegli sfondo:" \
         -mesg "Muovi su/giu per cambiare preview" \
         -input-reading $FIFO)

# Pulisce e termina ueberzug
kill $!       # uccide il demone in background
rm $FIFO

# Selezione valida?
[[ -z $selection ]] && exit 1

PAPER="$WALLPAPER_DIR/$selection"

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
