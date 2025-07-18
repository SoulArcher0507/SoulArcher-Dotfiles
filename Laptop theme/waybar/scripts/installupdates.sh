#!/bin/bash

set -euo pipefail

# 1) Chiedo subito la password sudo e tengo vivo il timestamp
sudo -v
trap 'kill 0' EXIT
while true; do sudo -n true; sleep 60; done &

# 2) Verifico la connessione a Internet
if ! ping -c1 archlinux.org &> /dev/null; then
  echo "Connessione a Internet assente."
  exit 1
fi

# 3) Prelevo in anticipo le liste dei pacchetti da aggiornare

# Pacman (solo nome pacchetto)
readarray -t PACMAN_UPDATES < <(pacman -Qu | awk '{print $1}')

# AUR (yay)
readarray -t AUR_UPDATES < <(yay -Qua | awk '{print $1}')

# Flatpak (solo le righe con " -> ", poi il primo campo)
readarray -t FLATPAK_UPDATES < <(flatpak update --dry-run 2>/dev/null \
  | grep ' -> ' \
  | awk '{print $1}')

# 4) Eseguo gli aggiornamenti

echo "🔄 Aggiornamento pacman..."
sudo pacman -Syu --noconfirm --needed

echo "📦 Aggiornamento AUR (yay)..."
yay -Syu --noconfirm --needed

echo "🖼️ Aggiornamento Flatpak..."
flatpak update -y

# 5) Riepilogo finale
echo -e "\n✅ Tutti gli aggiornamenti sono stati completati con successo!\n"
echo "––– RIEPILOGO DEI PACCHETTI AGGIORNATI –––"

echo -e "\n• Pacman:"
if [ ${#PACMAN_UPDATES[@]} -eq 0 ]; then
  echo "  (nessun pacchetto aggiornato)"
else
  for pkg in "${PACMAN_UPDATES[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\n• AUR (yay):"
if [ ${#AUR_UPDATES[@]} -eq 0 ]; then
  echo "  (nessun pacchetto aggiornato)"
else
  for pkg in "${AUR_UPDATES[@]}"; do
    echo "  - $pkg"
  done
fi

echo -e "\n• Flatpak:"
if [ ${#FLATPAK_UPDATES[@]} -eq 0 ]; then
  echo "  (nessun pacchetto aggiornato)"
else
  for pkg in "${FLATPAK_UPDATES[@]}"; do
    echo "  - $pkg"
  done
fi

echo
read -n1 -r -p "Premi un tasto per chiudere..." key
echo