#!/bin/bash

# Directory di destinazione
TARGET_DIR="$HOME/.config/rofi"
TARGET_FILE="current-wallpaper.rasi"

# Assicurati che esista
mkdir -p "$TARGET_DIR"

# Genera il file .rasi
cat > "${TARGET_DIR}/${TARGET_FILE}" <<EOF
* {
    current-image: url("${HOME}/Pictures/Wallpapers/active/active.jpg", height);
}
EOF

echo "Generato ${TARGET_DIR}/${TARGET_FILE}"
