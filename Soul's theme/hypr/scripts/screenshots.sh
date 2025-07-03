#!/bin/bash
mkdir -p $HOME/Pictures/Screenshots
grim - | tee $HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy
