{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.exec-once = [
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "hyprctl setcursor Bibata-Modern-Classic 22"
    "$scripts/monitors-toggle.sh"
    "qs" # quickshell
  ] ++ lib.optionals (settings.machine == "asus") [
      # "hyprctl keyword monitor DP-1, 2560x1440@165.00Hz, 0x0, 1"
      # "hyprctl keyword monitor eDP-1, 2560x1600@120.00Hz, 0x0, 2"
    "brightnessctl -d amdgpu_bl2 set 85"
    "asusctl -c 60"
  ];
}
