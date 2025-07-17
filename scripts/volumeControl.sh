#!/usr/bin/env bash

steps=5

muteUnmute() {
    # Function to check if muted
    is_muted() {
        amixer get Master | grep -q '\[off\]'
        return $?
    }

    # Get mute status
    if is_muted; then
        # Unmute
        amixer set Master on
    else
        # Mute
        amixer set Master off
        # echo "Master muted"
    fi
}

increaseVolume() {
    currentVolume=$(amixer sget Master | awk -F"[][]" '/Front Left:/ { print $2 }' | tr -d '%')

    if [ "$currentVolume" -le "$((100 - steps))" ]; then
        newVolume=$((currentVolume + steps))
        amixer set Master "$newVolume%"
    else
        newVolume=100
    fi
    amixer set Master on
}

decreaseVolume() {
    currentVolume=$(amixer sget Master | awk -F"[][]" '/Front Left:/ { print $2 }' | tr -d '%')

    newVolume=$((currentVolume - steps))

    if [ "$currentVolume" -ge "$steps" ]; then
        amixer set Master "$newVolume%"
    else
        amixer set Master 0
    fi
    amixer set Master on
}

# Get volume control action from command line argument
case "$1" in
    "--inc")
        increaseVolume
        ;;
    "--dec")
        decreaseVolume
        ;;
    "--mute")
        muteUnmute
        ;;
    *)
        echo "Usage: $0 [--inc|--dec|--mute]"
        exit 1
        ;;
esac
