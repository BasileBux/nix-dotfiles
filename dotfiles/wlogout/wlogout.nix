{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  programs.wlogout = {
    enable = true;

    layout = [
      {
        label = "shutdown";
        action = "systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "reboot";
        action = "systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
      {
        label = "logout";
        action = "loginctl terminate-user $USER";
        text = "Logout";
        keybind = "o";
      }
      {
        label = "lock";
        action = "hyprlock";
        text = "lock";
        keybind = "l";
      }
      {
        label = "sleep";
        action = "systemctl suspend";
        text = "sleep";
        keybind = "e";
      }
    ];

    style = ''
      * {
          text-shadow: 0px 0px;
          box-shadow: 0px 0px;
      }

      window {
          font-family: GeistMono NF Medium;
          font-size: 14pt;
          color: ${colors.wlogout.text};
          background-color: alpha(${colors.wlogout.background}, 0.5);
      }

      button {
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border: none;
          background-color: alpha(${colors.wlogout.background}, 0.5);
          margin: 5px;
          transition: box-shadow 0.2s ease-in-out, background-color 0.2s ease-in-out;
          color: ${colors.wlogout.text};
      }

      button:hover {
          background-color: ${colors.wlogout.hoverBackground};
          color: ${colors.wlogout.hoverText};
      }

      #logout {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/logout.png"));
      }
      #logout:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/logout-hover.png"));
      }

      #lock {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/lock.png"));
      }
      #lock:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/lock-hover.png"));
      }

      #suspend {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/sleep.png"));
      }
      #suspend:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/sleep-hover.png"));
      }

      #shutdown {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/power.png"));
      }
      #shutdown:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/power-hover.png"));
      }

      #reboot {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/restart.png"));
      }
      #reboot:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/restart-hover.png"));
      }
      #sleep {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/hibernate.png"));
      }
      #sleep:hover {
          background-image: image(url("${settings.configPath}/dotfiles/wlogout/icons/hibernate-hover.png"));
      }
    '';
  };
}
