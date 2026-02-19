#!/usr/bin/env bash
base="$(hyprctl getoption input:kb_options -j | jq -r '.str')"
suffix=",altwin:swap_lalt_lwin"

if [[ $base == *"$suffix" ]]; then
    new=${base%"$suffix"}
else
    new=$base$suffix
fi

hyprctl keyword input:kb_options "$new"
