#!/usr/bin/env bash

if pgrep waybar > /dev/null; then
    pkill -f waybar
else
    waybar &
fi
