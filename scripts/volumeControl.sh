#!/usr/bin/env bash

steps=5

# Get volume control action from command line argument
case "$1" in
    "--inc")
        pamixer --increase "$steps"
        ;;
    "--dec")
        pamixer --decrease "$steps"
        ;;
    "--mute")
        pamixer --toggle-mute
        ;;
    *)
        echo "Usage: $0 [--inc|--dec|--mute]"
        exit 1
        ;;
esac
