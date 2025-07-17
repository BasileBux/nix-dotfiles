#!/usr/bin/env bash

# Get media control action from command line argument
case "$1" in
    "--next")
        playerctl next
        ;;
    "--prev")
        playerctl previous
        ;;
    "--pause")
        playerctl play-pause
        ;;
    *)
        echo "Usage: $0 [--next|--prev|--pause]"
        exit 1
        ;;
esac
