{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.exec-once = [
    "swaybg -i $wallpaper -m fill"
    "waybar"
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "hyprctl setcursor Bibata-Modern-Classic 22"
    "$scripts/monitors-toggle.sh"
  ] ++ lib.optionals (settings.machine == "asus") [
    "brightnessctl -d amdgpu_bl2 set 85"
    "asusctl -c 60"
  ];
}
