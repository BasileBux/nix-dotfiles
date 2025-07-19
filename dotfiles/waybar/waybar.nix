{ config, pkgs, settings, colors, ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "custom/player" ];
        modules-right = [
          "pulseaudio"
          "network"
          "battery"
          # "battery#bat2"
          "clock"
          "custom/wlogout"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          disable-markup = true;
          all-outputs = true;
          format = " {icon} ";
          format-icons = {
            "active" = "";
            "empty" = "";
            "default" = "";
          };
          persistent-workspaces = { "*" = 5; };
        };
        "clock" = {
          tooltip-format = "{:%d-%m-%Y | %H:%M}";
          format-alt = "{:%d-%m-%Y}";
        };
        "cpu" = { format = "{usage}%  "; };
        "battery" = {
          states = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          format = "{icon}  {capacity}%";
          tooltip-format = "{power}W";
          format-icons = [ "" "" "" "" "" ];
        };
        "battery#bat2" = { bat = "BAT2"; };
        "network" = {
          format-wifi = " ";
          format-ethernet = " 󰛳 ";
          format-disconnected = " 󰖪 ";
          tooltip-format = "{essid} {rignalStrength}%";
          interval = 7;
          on-click = "nm-connection-editor";
        };
        "pulseaudio" = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-muted = "{volume}% ";
          format-icons = {
            "headphones" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" ];
          };
          on-click = "pavucontrol";
        };
        "bluetooth" = {
          format = "  ";
          tooltip-format = "{status}";
          on-click = "blueman-manager";
        };
        "custom/player" = {
          interval = 1;
          return-type = "json";
          exec = "${settings.configPath}/dotfiles/waybar/player.sh";
          exec-if = "pgrep spotify || pgrep zen";
          escape = true;
          tooltip = true;
        };

        "custom/wlogout" = {
          tooltip = true;
          tooltip-format = "Power menu";
          format = "";
          on-click = "${settings.configPath}/dotfiles/waybar/wlogout.sh";
        };
      };

    };
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: GeistMono NF;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background-color: transparent;
        border: 0px solid alpha(${colors.waybar.border}, 0.3);
        color: ${colors.waybar.text};
      }

      .modules-left {
        background-color: alpha(${colors.waybar.background}, 0.75);
        border-radius: 6px;
        margin-top: 3px;
        margin-left: 3px;
      }

      .modules-center {
        background-color: alpha(${colors.waybar.background}, 0.75);
        padding: 0px 10px;
        border-radius: 6px;
        margin-top: 3px;
      }

      .modules-right {
        background-color: alpha(${colors.waybar.background}, 0.75);
        border-radius: 6px;
        padding: 0px 6px;
        margin-top: 3px;
        margin-right: 3px;
      }

      window#waybar.hidden {
        opacity: 0;
      }

      #workspaces {
        margin-left: 3px;
        margin-right: 3px;
        padding: 0 5px;
      }

      #workspaces button {
        padding: 0 1px;
        background: transparent;
        border-bottom: 0px solid transparent;
        min-width: 0px;
        color: ${colors.waybar.text};
      }

      #workspaces button.active {
        color: ${colors.waybar.accent0};
      }

      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
        color: ${colors.waybar.accent1};
      }

      #workspaces button.urgent {
        background-color: ${colors.waybar.red};
      }

      #clock,
      #battery,
      #network,
      #pulseaudio,
      #cpu #custom-player {
        padding: 0 6px;
        margin: 0 5px;
      }

      #custom-wlogout {
        border-radius: 0.5rem;
        padding: 0px 16px 0px 6px;
        font-size: 12px;
        /* add padding to left to keep it from being sticked to the left side*/
      }

      #clock:hover,
      #battery:hover,
      #network:hover,
      #pulseaudio:hover,
      #cpu:hover,
      #custom-player:hover,
      #custom-wlogout:hover {
        color: ${colors.waybar.accent1};
      }

      #cpu {
        padding: 0 3px;
        margin: 0 0px;
      }

      #battery.warning {
        color: ${colors.waybar.yellow};
        border-radius: 6px;
      }

      #battery.critical {
        color: ${colors.waybar.red};
        border-radius: 6px;
      }

      #battery.charging {
        color: ${colors.waybar.green};
        border-radius: 6px;
      }

      tooltip {
        background-color: ${colors.waybar.background};
        border-radius: 3px;
      }

      tooltip label {
        color: ${colors.waybar.text};
      }
    '';
  };
}
