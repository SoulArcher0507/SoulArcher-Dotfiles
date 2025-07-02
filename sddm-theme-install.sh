#!/bin/bash

set -euo pipefail

# Controlla che la directory 'sequoia' esista nella cartella corrente
if [[ ! -d "sequoia" ]]; then
  echo "Errore: directory 'sequoia' non trovata nella cartella corrente."
  exit 1
fi

# Copia ricorsivamente la cartella in /usr/share/sddm/themes
echo "Copio 'sequoia' in /usr/share/sddm/themes/..."
sudo cp -r sequoia /usr/share/sddm/themes/

# Verifica o crea il file di configurazione /etc/sddm.conf
CONFIG_FILE="/etc/sddm.conf"
THEME_CONFIG="[Theme]\nCurrent=sequoia\n"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Creo il file di configurazione $CONFIG_FILE e imposto il tema Sequoia"
  printf "%b" "$THEME_CONFIG" | sudo tee "$CONFIG_FILE" > /dev/null
else
  echo "Il file $CONFIG_FILE esiste già. Aggiungo la configurazione in fondo."
  printf "%b" "$THEME_CONFIG" | sudo tee -a "$CONFIG_FILE" > /dev/null
fi

echo "Operazione completata con successo."

