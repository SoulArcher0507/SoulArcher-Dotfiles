#!/bin/bash

res_w=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
res_h=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
h_scale=$(hyprctl -j monitors | jq '.[] | select (.focused == true) | .scale' | sed 's/\.//')

# Calcola il margin verticale in base all'altezza e alla scala
w_margin=$(( res_h * 27 / scale ))

# Lancia wlogout con i bordi calcolati
# wlogout -b 5
# wlogout -b 5 -R "$w_margin" -L "$w_margin"
wlogout -b 5 -T "$w_margin" -B "$w_margin"
# wlogout -b 5 -m "$w_margin"