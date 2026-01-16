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
    hyprpolkitagent
  ];

  services.swaync.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;
    settings = {
      "$mainMod" = "SUPER";
      "$scripts" = "${settings.configPath}/scripts";
      "$terminal" = "kitty";

      env = [
        "HYPRCURSOR_THEME,Bibata-Modern-Classic"
        "HYPRCURSOR_SIZE,22"
        "XCURSOR_SIZE, 24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      monitor = if (settings.machine == "asus") then [
        "desc:Thermotrex Corporation TL140ADXP01, 2560x1600@60.00Hz, 0x0, 1.6"
        "DP-1, 2560x1440@165.00Hz, auto, 1" # No HDR
        # "DP-1, 2560x1440@165.00Hz, auto, 1, bitdepth, 10, cm, hdr,sdrbrightness,1.2,sdrsaturation,1.2" # With HDR
        ",preferred, auto, auto, mirror, eDP-2"
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
        border_size = 2;
        "col.active_border" = "0xA9464646";
        "col.inactive_border" = "0x00000000";
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
        dim_strength = 0.2;
      };
      animations = {
        enabled = true;
        bezier = [ "pop, 0.39, 0.575, 0.565, 1" "linear, 0.5, 0.5, 0.5, 0.5" ];
        animation = [
          "windows, 1, 2, pop, popin 80%"
          "windowsOut, 1, 3, default, popin 70%"
          "fade, 0"
          "workspaces, 1, 0.6, linear, slide"
          "specialWorkspaceIn, 1, 1.2, linear, slidevert top"
          "specialWorkspaceOut, 1, 1.2, linear, slidevert bottom"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      xwayland.force_zero_scaling = true;
      gesture = [ "3, horizontal, workspace" ];

      input = {
        kb_layout = "us,ch";
        kb_variant = ",fr";
        kb_options = "grp:alt_space_toggle,ctrl:nocaps${
            lib.optionalString settings.swapAltSuper ",altwin:swap_lalt_lwin"
          }";
        follow_mouse = 1;
        touchpad = { natural_scroll = true; };
        sensitivity = 0; # -1.0 to 1.0, 0 means no modification.

        repeat_delay = 250;
        repeat_rate = 35;
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
        {
          name = "logitech-pro-x-wireless-1";
          sensitivity = -0.2;
          accel_profile = "flat";
        }
        {
          name = "logitech-pro-x-wireless-2";
          sensitivity = -0.2;
          accel_profile = "flat";
        }
      ];
    };
  };
}
