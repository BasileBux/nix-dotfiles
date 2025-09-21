{ lib, config, pkgs, inputs, settings, ... }:

{
  imports = [ ./keybinds.nix ./startup.nix ./windowrules.nix ];

  # Dependencies for the Hyprland setup
  home.packages = with pkgs; [
    bibata-cursors
    hyprcursor
    playerctl
    hypridle
    grim
    slurp
    hyprlock
    brightnessctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mainMod" = "SUPER";
      "$scripts" = "${settings.configPath}/scripts";
      "$terminal" = "ghostty";

      env = [
        "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        "HYPRCURSOR_SIZE,22"
        "XCURSOR_SIZE, 24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      monitor = if (settings.machine == "asus") then [
        "eDP-1, 2560x1600@60.00Hz, 0x0, 1.6"
        "eDP-2, 2560x1600@60.00Hz, 0x0, 1.6"
        "DP-1, 2560x1440@165.00Hz, 0x0, 1"
        ",preferred, auto, auto, mirror, eDP-1"
      ] else if (settings.machine == "thinkpad") then [
        "eDP-1, 1920x1080@60.01Hz, 0x0, 1.0"
        ",preferred, auto, auto, mirror, eDP-1"
      ] else
        [ ",preferred,auto,auto" ];

      cursor.enable_hyprcursor = true;

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      general = {
        gaps_in = 1;
        gaps_out = 3;
        border_size = 0;
        "col.active_border" = "0xb9aa2284"; # 0x99fe97e1
        "col.inactive_border" = "0x00000000"; # 0xff363a4f
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 7;
        blur = {
          enabled = true;
          size = 4;
          passes = 1;
        };
        dim_inactive = true;
        dim_strength = 0.1;
      };
      animations = {
        enabled = true;
        # Custom animations really fast
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [

          "windows, 1, 5, myBezier, popin 80%"
          "windowsOut, 1, 4, default, popin 70%"
          "border, 1, 3, default"
          "borderangle, 1, 8, default"
          "fade, 1, 6, default"
          "workspaces, 1, 1.7, myBezier, fade"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      xwayland.force_zero_scaling = true;
      gesture = [
        "3, horizontal, workspace"
      ];

      input = {
        kb_layout = "us,ch";
        kb_variant = ",fr";
        kb_options = "grp:alt_shift_toggle,ctrl:nocaps${
            lib.optionalString settings.swapAltSuper ",altwin:swap_lalt_lwin"
          }";
        follow_mouse = 1;
        touchpad = { natural_scroll = true; };
        sensitivity = 0; # -1.0 to 1.0, 0 means no modification.

        repeat_delay = 250;
        repeat_rate = 30;
      };

      device = [
        {
          name = "logitech-usb-receiver";
          sensitivity = -0.2;
          accel_profile = "flat";
        }
        {
          name = "elan-touchscreen";
          enabled = false;
        }
      ];
    };
  };
}
