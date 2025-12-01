{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.exec-once = [
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "hyprctl setcursor Bibata-Modern-Classic 22"
    "qs" # quickshell
  ] ++ lib.optionals (settings.machine == "asus") [
    "brightnessctl -d amdgpu_bl2 set 85"
    "asusctl -c 80"
  ];
}
