{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.windowrule = [
    # "suppressevent maximize, class:.*"
    "match:title Picture-in-Picture, float true"
    "match:title quickshell, float true"
    "match:class Emulator, float true"

    "match:title sagepopup, float true"
    "match:title sagepopup, size (monitor_w*0.6) (monitor_h*0.3)"
    "match:title sagepopup, move (monitor_w*0.2) (monitor_h*0.02)"
    # move 50-(60/2)=20% horizontally to center

    "match:title scratch, float true"
    "match:title scratch, size (monitor_w*0.8) (monitor_h*0.8)"
    "match:title scratch, move (monitor_w*0.1) (monitor_h*0.1)"
    # move 50-(80/2)=10% horizontally to center
    # move 50-(80/2)=10% vertically to center

    
    # Might be useful later
    # "noblur, title:quickshell"
    # "noshadow, title:quickshell"
    # "noborder, title:quickshell"
  ];
  wayland.windowManager.hyprland.settings.workspace = [
    "special:sagepopup, on-created-empty:kitty --title='sagepopup' -e sage"
    "special:scratch, on-created-empty:kitty --title='scratch' -e sh nvim ~/tmp/notes/daily-$(date +%d-%b-%Y).md"
  ];
}
