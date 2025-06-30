#!/usr/bin/env bash
# Script: wifi-menu.sh
# Usa nmcli per elencare le reti Wi-Fi e rofi per selezione/connessione.

# 1. Ottieni lista di SSID (senza duplicati), mostrando solo aperte e protette
mapfile -t list < <(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: '$1!="" {print $1 "\t" $2}' | sort -u)

# Prepara menu per rofi: “SSID [SICURO]” o “SSID [APERTA]”
options=()
for line in "${list[@]}"; do
    ssid="${line%%$'\t'*}"
    sec="${line##*$'\t'}"
    if [[ "$sec" == "--" ]]; then
        options+=("$ssid [Open]")
    else
        options+=("$ssid [Secured]")
    fi
done

# Aggiungi voce per disconnettere o aprire configurazioni
options+=("Disconnect")
options+=("Edit connections (nm-connection-editor)")
options+=("Cancel")

# Lancia rofi
chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Wi-Fi:")

if [[ -z "$chosen" ]] || [[ "$chosen" == "Cancel" ]]; then
    exit 0
elif [[ "$chosen" == "Disconnect" ]]; then
    # Disconnette l’interfaccia Wi-Fi attiva
    iface=$(nmcli -t -f DEVICE,TYPE,STATE dev status | awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}')
    if [[ -n "$iface" ]]; then
        nmcli dev disconnect "$iface"
    fi
    exit 0
elif [[ "$chosen" == "Edit connections (nm-connection-editor)" ]]; then
    nm-connection-editor &
    exit 0
else
    # Estrai SSID selezionato (rimuovi eventuale [Open]/[Secured])
    ssid=$(echo "$chosen" | sed 's/ \[.*\]$//')
    # Controlla se rete protetta
    sec=$(nmcli -t -f SSID,SECURITY dev wifi list | awk -F: -v s="$ssid" '$1==s {print $2; exit}')
    if [[ "$sec" == "--" ]]; then
        # Rete aperta
        nmcli dev wifi connect "$ssid"
    else
        # Rete protetta: chiede password via rofi -password
        passwd=$(rofi -dmenu -password -p "Password for $ssid:")
        if [[ -n "$passwd" ]]; then
            nmcli dev wifi connect "$ssid" password "$passwd"
        fi
    fi
    exit 0
fi
