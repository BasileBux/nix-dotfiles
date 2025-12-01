#! /usr/bin/env sh

INTERNAL_DESC="Thermotrex Corporation TL140ADXP01"
EXT="DP-1"

if hyprctl monitors all -j | jq -e '.[] | select(.name == "'"$EXT"'")' >/dev/null; then
    hyprctl keyword monitor "desc:$INTERNAL_DESC",disable
    pkill quickshell
    quickshell -d
else
    hyprctl keyword monitor "desc:$INTERNAL_DESC",2560x1600@60Hz,0x0,1.6
    pkill quickshell
    quickshell -d
fi
