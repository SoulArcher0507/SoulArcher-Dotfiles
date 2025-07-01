#|/bin/bash

set -euo pipefail

# Se non siamo root, useremo sudo per pacman e AUR helper
if [[ $EUID -ne 0 ]]; then
  SUDO='sudo'
else
  SUDO=''
fi

echo "🔄 Aggiornamento database e pacchetti ufficiali (pacman)..."
$SUDO pacman -Syu --noconfirm --needed

echo "📦 Aggiornamento pacchetti AUR..."
$SUDO yay -Syu --noconfirm --needed

echo "🖼️  Aggiornamento Flatpak..."
flatpak update -y

echo
echo "✅ Tutti gli aggiornamenti sono stati completati con successo!"
