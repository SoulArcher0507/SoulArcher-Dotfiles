#!/bin/bash

# Directory di destinazione nel profilo utente
DEST="$HOME/.config/environment.d"
FILE="$DEST/gtk-theme.conf"

# Creazione directory se non esiste
mkdir -p "$DEST"

# Scrittura del file
cat > "$FILE" <<EOF
GTK_THEME=Adwaita:dark
EOF

echo "Creato $FILE con GTK_THEME=Adwaita:dark"
