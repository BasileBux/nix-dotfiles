{ config, pkgs, inputs, settings, lib, ... }:

{
  wayland.windowManager.hyprland.settings.windowrulev2 =
    [ "suppressevent maximize, class:.*" ];
}
