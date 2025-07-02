#!/bin/bash

set -euo pipefail   # struttura di controllo per errori

if [[ $EUID -ne 0 ]]; then  # root enabler
  echo "Lo script deve essere lanciato da root"
  exec sudo "$0" "$@"
fi

if ! ping -c1 archlinux.org &> /dev/null; then  # verifica connessione internet
  echo "Connessione a Internet assente."
  exit 1
fi

PACMAN_CONF="/etc/pacman.conf"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP="${PACMAN_CONF}.bak.${TIMESTAMP}"

# Backup del file di configurazione
cp "$PACMAN_CONF" "$BACKUP"
echo "Backup di $PACMAN_CONF creato in $BACKUP"

# Uncomment delle righe [multilib] e Include
sed -i '/^[[:space:]]*#\s*\[multilib\]/s/^#\s*//' "$PACMAN_CONF"
sed -i '/^[[:space:]]*#\s*Include\s*=\s*\/etc\/pacman.d\/mirrorlist/s/^#\s*//' "$PACMAN_CONF"

echo "Sezione [multilib] abilitata in $PACMAN_CONF"

echo "Aggiornamento database pacman..."
pacman -Sy --noconfirm

# Prompt per pacchetti opzionali
read -p "Vuoi installare i pacchetti di development (dev.txt)? [y/N]: " DEV_ANSWER
INSTALL_DEV=false
if [[ "$DEV_ANSWER" =~ ^[Yy] ]]; then
  INSTALL_DEV=true
fi

read -p "Vuoi installare i pacchetti per il gaming (gaming.txt)? [y/N]: " GAMING_ANSWER
INSTALL_GAMING=false
if [[ "$GAMING_ANSWER" =~ ^[Yy] ]]; then
  INSTALL_GAMING=true
fi

PACMAN_PACKAGES=()
AUR_PACKAGES=()
FLAT_PACKAGES=()

read_packages() {
  local file="$1"
  local -n arr_ref="$2"
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    arr_ref+=("$pkg")
  done < "$file"
}

# Caricamento pacchetti da pacman
for file in pkgs/pacman/*.txt; do
  [[ -f "$file" ]] || continue
  base=$(basename "$file")
  # Salta i dev.txt e gaming.txt se disabilitati
  if [[ "$base" == "dev.txt" && "$INSTALL_DEV" != true ]]; then
    continue
  fi
  if [[ "$base" == "gaming.txt" && "$INSTALL_GAMING" != true ]]; then
    continue
  fi
  echo "Caricamento pacman: $base"
  read_packages "$file" PACMAN_PACKAGES
done

# Caricamento pacchetti da AUR
for file in pkgs/aur/*.txt; do
  [[ -f "$file" ]] || continue
  base=$(basename "$file")
  if [[ "$base" == "dev.txt" && "$INSTALL_DEV" != true ]]; then
    continue
  fi
  if [[ "$base" == "gaming.txt" && "$INSTALL_GAMING" != true ]]; then
    continue
  fi
  echo "Caricamento AUR: $base"
  read_packages "$file" AUR_PACKAGES
done

# Caricamento pacchetti da flatpak
for file in pkgs/flatpak/*.txt; do
  [[ -f "$file" ]] || continue
  base=$(basename "$file")
  if [[ "$base" == "dev.txt" && "$INSTALL_DEV" != true ]]; then
    continue
  fi
  if [[ "$base" == "gaming.txt" && "$INSTALL_GAMING" != true ]]; then
    continue
  fi
  echo "Caricamento flatpak: $base"
  read_packages "$file" FLAT_PACKAGES
done

install_pacman_pkgs() { # pacman installer
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &> /dev/null; then
      echo "$pkg già installato"
    else
      echo "Installazione di $pkg…"
      pacman -S --noconfirm --needed "$pkg"
    fi
  done
}

install_aur_pkgs() {    # yay installer
  local pkgs=("$@")
  # determina l'utente reale (quello che ha lanciato sudo)
  local real_user="${SUDO_USER:-$(id -un)}"
  for pkg in "${pkgs[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
      echo "$pkg (AUR) già installato"
    else
      echo "Installazione di $pkg da AUR…"
      # esegue yay come utente reale, con HOME settata correttamente
      sudo -H -u "$real_user" yay -S --noconfirm --needed "$pkg"
    fi
  done
}

install_flat_pkgs() {    # flatpak installer
  local pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    # controlla se già presente fra le app Flatpak installate
    if flatpak list --app | awk '{print $1}' | grep -qx "$pkg"; then
      echo "$pkg (FLATPAK) già installato"
    else
      echo "Installazione di $pkg da FLATPAK…"
      flatpak install -y flathub "$pkg"
    fi
  done
}

if [ ${#PACMAN_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da pacman ==="
  install_pacman_pkgs "${PACMAN_PACKAGES[@]}"
fi

if [ ${#AUR_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da AUR ==="
  install_aur_pkgs "${AUR_PACKAGES[@]}"
fi

if [ ${#FLAT_PACKAGES[@]} -gt 0 ]; then
  echo "=== Installazione pacchetti da FLATPAK ==="
  install_flat_pkgs "${FLAT_PACKAGES[@]}"
fi

echo "=== Installazione riuscita ==="
