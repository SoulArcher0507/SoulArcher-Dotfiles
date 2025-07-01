#|/bin/bash

set -euo pipefail

if ! ping -c1 archlinux.org &> /dev/null; then  # verifica connessione internet
  echo "Connessione a Internet assente."
  exit 1
fi

echo "Aggiornamento pacchetti AUR..."
$SUDO yay -Syu --noconfirm --needed

echo "Aggiornamento pacchetti Flatpak..."
flatpak update -y

if [[ $EUID -ne 0 ]]; then  # root enabler
  echo "Lo script deve essere lanciato da root"
  exec sudo "$0" "$@"
fi

echo "Aggiornamento pacchetti pacman..."
$SUDO pacman -Syu --noconfirm --needed



echo
echo "✅ Tutti gli aggiornamenti sono stati completati con successo!"
