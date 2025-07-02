#!/bin/bash

# Recupera width, height e scale dell'output focalizzato
read -r res_w res_h scale <<EOF
$(swaymsg -t get_outputs -r -p | jq -r '.[] | select(.focused==true) | "\(.width) \(.height) \(.scale)"')
EOF

# Calcola il margin verticale in base all'altezza e alla scala
w_margin=$(( res_h * 27 / scale ))

# Lancia wlogout con i bordi calcolati
# wlogout -b 5
wlogout -b 5 -R "$w_margin" -L "$w_margin" -T "$w_margin*2" -B "$w_margin*2"
# wlogout -b 5 -T "$w_margin" -B "$w_margin"
# wlogout -b 5 -m "$w_margin"