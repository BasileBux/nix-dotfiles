#!/usr/bin/env bash

increaseKbBacklight(){
    max=3
    current=$(brightnessctl -d asus::kbd_backlight get)

    new=$((current + 1))

    if [ "$new" -le "$max" ];then
    brightnessctl -d asus::kbd_backlight set "$new"
    fi
}

decreaseKbBacklight(){
    current=$(brightnessctl -d asus::kbd_backlight get)

    new=$((current - 1))

    if [ "$new" -ge 0 ];then
    brightnessctl -d asus::kbd_backlight set "$new"
    fi
}

# Get kb backlight control action from command line argument
case "$1" in
    "--inc")
        increaseKbBacklight
        ;;
    "--dec")
        decreaseKbBacklight
        ;;
    *)
        echo "Usage: $0 [--inc|--dec]"
        exit 1
        ;;
esac
