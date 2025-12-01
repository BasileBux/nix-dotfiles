{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.windowrule = [
    "suppressevent maximize, class:.*"
    "float, title:Picture-in-Picture"
    "float, title:quickshell"
    "float, class:Emulator"

    # "workspace special:sagepopup, float, size 45% 35%, move 50% 5%, title:sagepopup"
    "workspace special:sagepopup, title:^(sagepopup)$"
    "float, title:^(sagepopup)$"
    "size 60% 30%, title:^(sagepopup)$"
    "move 20% 2%, title:^(sagepopup)$"
    # move 50-(60/2)=20% horizontally to center

    # Might be useful later
    # "noblur, title:quickshell"
    # "noshadow, title:quickshell"
    # "noborder, title:quickshell"
  ];
  wayland.windowManager.hyprland.settings.workspace = [
    "special:sagepopup, on-created-empty:ghostty --title='sagepopup' -e sage"
  ];
}
