#!/usr/bin/env bash

if pgrep waybar >/dev/null; then
    pkill waybar
    sleep 0.2
fi

# Start waybar
waybar &

# Check if swaybg is running and stop it
if pgrep swaybg >/dev/null; then
    pkill swaybg
fi

# Set wallpaper
sh ~/.config/hypr/scripts/randomWallpaper.sh
swaybg -i ~/wallpaper.png -m fill &

