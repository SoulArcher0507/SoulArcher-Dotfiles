# Sway-Config

- _Screenshots_
- Login Configuration
- _Wallpaper_
- _Idle_ 
- _Animazioni_
- _Autostart_
- _Cursor_
- _Decoration_
- _Environment_
- _Keybindings_
- _Layout_
- _Misc_
- _Window_
- _Windowrule_
- _Workspace_
- _Waybar config_ 
- _Waybar modules_
- _Rofi_
- _wlogout_
- _Wal_
- _Blurred and Square Wallpaper_
- _Modulo waybar swayidle_
- _Cliphist_
- _Riscrivere colori per waybar e rofi usando lo script di Lore_
- _Dolphin fix_
- _Colori Hyprland_
- _Swaync_
-- Modulo Waybar Kdeconnect
- _Colori Waybar, Swaync, rofi_
- Notifiche che se ripremo te chiude


Nello script di installazione attivare i servizi che richiedono attivazione:
- systemctl --user enable --now swaync.service      systemctl --user start --now swaync.service
- sudo systemctl enable --now power-profiles-daemon.service


Nello script attivare multilib di pacman

Runnare questo comando dopo installazione per dolphin
XDG_MENU_PREFIX=arch- kbuildsycoca6