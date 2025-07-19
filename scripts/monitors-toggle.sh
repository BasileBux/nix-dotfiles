#! /usr/bin/env sh

# Internal is eDP-1 when asusMuxDGPU is enabled and eDP-2 when it is disabled
# Add support for this automation

DGPU_INTERNAL_MONITOR="eDP-1"
INTEGRATED_INTERNAL_MONITOR="eDP-2"
EXTERNAL_MONITOR1="DP-1"

NUM_MONITORS=$(hyprctl monitors all | grep Monitor | wc --lines)
NUM_MONITORS_ACTIVE=$(hyprctl monitors | grep Monitor | wc --lines)

kill_hypridle() {
    if pgrep hypridle >/dev/null; then
        pkill hypridle
    fi
}

if [ $NUM_MONITORS -gt 1 ]; then
    kill_hypridle
    hyprctl keyword monitor "$DGPU_INTERNAL_MONITOR, disable"
    hyprctl keyword monitor "$INTEGRATED_INTERNAL_MONITOR, disable"

    # Monitors
    hyprctl keyword workspace "1,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "2,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "3,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "4,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "5,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "6,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "7,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "8,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "9,monitor:$EXTERNAL_MONITOR1"
    hyprctl keyword workspace "10,monitor:$EXTERNAL_MONITOR1"

fi

# I you want to use both monitors uncomment under this and comment other if
# if [ $NUM_MONITORS -gt 1 ]; then
#     killall hypridle
#     hyprctl keyword monitor "$DGPU_INTERNAL_MONITOR, 2560x1600@120.00Hz, -1280x0, 2"
#     hyprctl keyword monitor "$INTEGRATED_INTERNAL_MONITOR, 2560x1600@120.00Hz, -1280x0, 2"
#
#     # Monitors
#     hyprctl keyword workspace "1,monitor:$EXTERNAL_MONITOR1"
#     hyprctl keyword workspace "2,monitor:$EXTERNAL_MONITOR1"
#     hyprctl keyword workspace "3,monitor:$EXTERNAL_MONITOR1"
#     hyprctl keyword workspace "4,monitor:$EXTERNAL_MONITOR1"
#     hyprctl keyword workspace "5,monitor:$EXTERNAL_MONITOR1"
#     hyprctl keyword workspace "6,monitor:$DGPU_INTERNAL_MONITOR"
#     hyprctl keyword workspace "7,monitor:$DGPU_INTERNAL_MONITOR"
#     hyprctl keyword workspace "8,monitor:$DGPU_INTERNAL_MONITOR"
#     hyprctl keyword workspace "9,monitor:$DGPU_INTERNAL_MONITOR"
#     hyprctl keyword workspace "10,monitor:$DGPU_INTERNAL_MONITOR"
#
# fi
