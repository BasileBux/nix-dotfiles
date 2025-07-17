{ config, pkgs, inputs, settings, ... }:

{
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" =
        "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo = {
        source = "${settings.configPath}/dotfiles/fastfetch/Sasaki-Kojiro.jpg";
        type = "kitty";
        height = 15;
        padding = {
          top = 2;
          left = 2;
        };
        printRemaining = false;
      };

      display = { separator = "    "; };

      modules = [
        {
          type = "custom";
          format = ''
            ┌─────────────────────────────────────────────────────────────┐
          '';
        }
        {
          type = "os";
          key = "  ";
          keyColor = "blue";
        }
        {
          type = "kernel";
          key = "  ";
          keyColor = "white";
        }
        {
          type = "packages";
          key = "  󰏖";
          keyColor = "red";
        }
        {
          type = "wm";
          key = "  󱄄";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "  ";
          keyColor = "magenta";
        }
        {
          type = "shell";
          key = "  ";
          keyColor = "yellow";
        }
        {
          type = "custom";
          format = " ";
        }
        {
          type = "custom";
          format = ''
            ├─────────────────────────────────────────────────────────────┤
          '';
        }
        {
          type = "host";
          key = "  ";
          keyColor = "blue";
        }
        {
          type = "cpu";
          key = "  ";
          keyColor = "red";
        }
        {
          type = "gpu";
          key = "  ";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "  ";
          keyColor = "yellow";
        }
        {
          type = "disk";
          key = "  ";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = " ";
        }
        {
          type = "custom";
          format =
            "└─────────────────────────────────────────────────────────────┘";
        }
      ];
    };
  };
}
