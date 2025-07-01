#!/bin/bash

# Numero di update da pacman (checkupdates è in pacman-contrib)
pacman_count=$(checkupdates 2>/dev/null | wc -l)

# Numero di update da AUR (yay)
aur_count=$(yay -Qu --quiet 2>/dev/null | wc -l)

# Numero di update da flatpak (skip prima riga di header)
flatpak_count=$(flatpak update --dry-run --app 2>/dev/null | tail -n +2 | wc -l)

# somma totale
total=$((pacman_count + aur_count + flatpak_count))

# scegli il colore in base al numero di update
if   [ "$total" -lt 25 ]; then      css_class="green"  #color="#99c794"   # verde
elif [ "$total" -lt 100 ]; then     css_class="yellow" #color="#fac863"   # giallo
else                                css_class="red"    #color="#ec5f67"   # rosso
fi

# esci in JSON per Waybar
echo "{\"text\":\"   $total\",\"tooltip\":\"pacman: $pacman_count | AUR: $aur_count | flatpak: $flatpak_count\",\"class\":\"$css_class\"}"
