#!/usr/bin/env bash
set -euo pipefail

# Percorso del file di configurazione
CONFIG="$HOME/.config/kdeglobals"

# Se non esiste la sezione [General], la aggiunge in coda
if ! grep -q '^\[General\]' "$CONFIG"; then
  echo -e "\n[General]" >> "$CONFIG"
fi

# Se esiste già una riga TerminalApplication=*, la sostituisce; altrimenti la inserisce subito dopo [General]
if grep -q '^TerminalApplication=' "$CONFIG"; then
  sed -i 's|^TerminalApplication=.*|TerminalApplication=alacritty|' "$CONFIG"
else
  # inserisce subito dopo la riga [General]
  sed -i '/^\[General\]/a TerminalApplication=alacritty' "$CONFIG"
fi

echo "→ Impostazione TerminalApplication=alacritty aggiunta/aggiornata in $CONFIG"