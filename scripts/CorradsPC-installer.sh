#!/bin/bash

set -euo pipefail   # Fail on errors, undefined variables, or pipe failures

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "Lo script deve essere lanciato da root, rilancio con sudo..."
  exec sudo "$0" "$@"
fi

# Check internet connection
if ! ping -c1 archlinux.org &> /dev/null; then
  echo "Connessione a Internet assente."
  exit 1
fi

# Directory contenente i file pacman.txt, aur.txt e flatpak.txt
PKG_DIR="../CorradsPC-pkgs"

# Array per i pacchetti
PACMAN_PACKAGES=()
AUR_PACKAGES=()
FLAT_PACKAGES=()

# Funzione di supporto: legge pacchetti da file di testo
read_packages() {
  local file="$1"
  local -n arr_ref="$2"
  if [[ ! -f "$file" ]]; then
    echo "File non trovato: $file"
    return
  fi
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    arr_ref+=("$pkg")
  done < "$file"
}

# Caricamento pacchetti dalle tre fonti
echo "Caricamento pacchetti da $PKG_DIR/pacman.txt"
read_packages "$PKG_DIR/pacman.txt" PACMAN_PACKAGES

echo "Caricamento pacchetti da $PKG_DIR/aur.txt"
read_packages "$PKG_DIR/aur.txt" AUR_PACKAGES

echo "Caricamento pacchetti da $PKG_DIR/flatpak.txt"
read_packages "$PKG_DIR/flatpak.txt" FLAT_PACKAGES

# Funzione: installazione pacchetti pacman
install_pacman_pkgs() {
  local pkgs=("${@}")
  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &> /dev/null; then
      echo "$pkg già installato"
    else
      echo "Installazione di $pkg..."
      pacman -S --noconfirm --needed "$pkg"
    fi
  done
}

# Funzione: installazione pacchetti AUR con yay
install_aur_pkgs() {
  local pkgs=("${@}")
  local real_user="${SUDO_USER:-$(id -un)}"
  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &> /dev/null; then
      echo "$pkg (AUR) già installato"
    else
      echo "Installazione di $pkg da AUR..."
      sudo -H -u "$real_user" yay -S --noconfirm --needed "$pkg"
    fi
  done
}

# Funzione: installazione pacchetti Flatpak
install_flat_pkgs() {
  local pkgs=("${@}")
  for pkg in "${pkgs[@]}"; do
    if flatpak list --app | awk '{print $1}' | grep -qx "$pkg"; then
      echo "$pkg (FLATPAK) già installato"
    else
      echo "Installazione di $pkg da FLATPAK..."
      flatpak install -y flathub "$pkg"
    fi
  done
}

# Esecuzione delle installazioni
if [ ${#PACMAN_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da pacman ==="
  install_pacman_pkgs "${PACMAN_PACKAGES[@]}"
fi

if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da AUR ==="
  install_aur_pkgs "${AUR_PACKAGES[@]}"
fi

if [ ${#FLAT_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da Flatpak ==="
  install_flat_pkgs "${FLAT_PACKAGES[@]}"
fi

echo "=== Installazione completata ==="
