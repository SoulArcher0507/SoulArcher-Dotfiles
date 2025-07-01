#!/bin/bash
set -euo pipefail

if [ $# -ne 3 ]; then
  cat <<EOF
Uso:
  $0 input.svg output.svg #RRGGBB

Esempio:
  $0 openai-white.svg openai-tint.svg #aabbcc
EOF
  exit 1
fi

INPUT_SVG="~/.config/waybar/assets/openai-white.svg"
OUTPUT_SVG="~/.config/waybar/assets/openai.svg"
NEWCOLOR="$1"

# Verifica che input esista
if [ ! -f "$INPUT_SVG" ]; then
  echo "Errore: '$INPUT_SVG' non trovato." >&2
  exit 2
fi

# Usa sed per sostituire SOLO il fill nell'elemento <svg ... fill="...">
# - la regex cerca "<svg" fino a "fill=" e cambia il valore tra virgolette
sed -E "0,/<svg[^>]*fill=\"[^\"]*\"/s|(<svg[^>]* )fill=\"[^\"]*\"|\1fill=\"$NEWCOLOR\"|" \
    "$INPUT_SVG" > "$OUTPUT_SVG"

echo "✅ Creato '$OUTPUT_SVG' con fill=\"$NEWCOLOR\""
