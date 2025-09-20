{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.windowrule = [
    "suppressevent maximize, class:.*"
    "float, title:Picture-in-Picture"
    "float, title:quickshell"
    "float, class:Emulator"

    # Might be useful later
    # "noblur, title:quickshell"
    # "noshadow, title:quickshell"
    # "noborder, title:quickshell"
  ];
}
