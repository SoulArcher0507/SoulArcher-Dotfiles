#!/bin/bash

set -euo pipefail   # abort on errors, unset variables

# Directory dello script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
# Determina la home dell'utente reale (non root)
if [[ -n "${SUDO_USER-}" ]]; then
  TARGET_HOME="$(eval echo "~$SUDO_USER")"
else
  TARGET_HOME="$HOME"
fi

# Installazione di yay (helper AUR) senza blocchi
if pacman -Qi "yay" &>/dev/null; then
  echo "yay (AUR) già installato"
else
  echo "=== Installazione di yay ==="
  SCRIPT=$(realpath "$0")
  temp_path=$(dirname "$SCRIPT")
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd $temp_path
  echo ":: yay has been installed successfully."
fi

# Invoca lo script di installazione pacchetti
echo "=== Avvio installazione pacchetti ==="
"$SCRIPT_DIR/packinstall.sh"

echo ""
# Determina la home dell'utente reale (non root)
if [[ -n "${SUDO_USER-}" ]]; then
  TARGET_HOME="$(eval echo "~$SUDO_USER")"
else
  TARGET_HOME="$HOME"
fi

CONFIG_DIR="$TARGET_HOME/.config"
# Crea la cartella .config se non esiste
mkdir -p "$CONFIG_DIR"

echo "Cartella di destinazione: $CONFIG_DIR"

SELECTED="Soul's theme"
echo "Installazione del tema '$SELECTED' in $CONFIG_DIR..."

# Copia ricorsiva del tema selezionato
rsync -av --progress "$SCRIPT_DIR/$SELECTED/" "$CONFIG_DIR/"

# dolphin fix
XDG_MENU_PREFIX=arch- kbuildsycoca6

"$SCRIPT_DIR/setup-wallpaper-rofi.sh"
"$SCRIPT_DIR/dolphin-terminal.sh"
sudo "$SCRIPT_DIR/sddm-theme-install.sh"

systemctl --user enable --now swaync.service
systemctl --user start --now swaync.service
sudo systemctl enable --now power-profiles-daemon.service

echo "=== Tema '$SELECTED' installato con successo! ==="
