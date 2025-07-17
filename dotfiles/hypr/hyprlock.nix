{ lib, config, pkgs, inputs, settings, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      background = [{
        path = "${settings.configPath}/dotfiles/hypr/wallpaper.png";

        blur_size = 4;
        blur_passes = 3;
        noise = 1.17e-2;
        contrast = 1.3;
        brightness = 0.8;
        vibrancy = 0.21;
        vibrancy_darkness = 0.0;
        hide_cursor = true;
      }];

      input-field = [{
        size = "250, 50";
        outline_thickness = 3;
        dots_size = 0.26; # Scale of input-field height, 0.2 - 0.8
        dots_spacing = 0.64; # Scale of dots' absolute size, 0.0 - 1.0
        dots_center = true;
        outer_color = "0xff1e2030";
        inner_color = "0xff1e2030";
        font_color = "0xffcad3f5";
        fade_on_empty = true;
        placeholder_text =
          "<i>Password...</i>"; # Text rendered in the input box when it's empty.
        hide_input = false;

        position = "0, 100";
        halign = "center";
        valign = "bottom";
      }];

      # Current time
      label = [
        {
          text = ''
            cmd[update:1000] echo "<b><big> $(date +"%H:%M:%S") </big></b>"
          '';
          color = "0xff8bd5ca";
          font_size = 64;
          font_family = "JetBrains Mono Nerd Font 10";
          shadow_passes = 3;
          shadow_size = 4;

          position = "0, 26";
          halign = "center";
          valign = "center";
        }

        # Date
        {
          text = ''
            cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"
          '';
          color = "0xffcad3f5";
          font_size = 24;
          font_family = "JetBrains Mono Nerd Font 10";

          position = "0, -56";
          halign = "center";
          valign = "center";
        }
        {
          text = "Hey $USER !";
          color = "0xffcad3f5";
          font_size = 18;
          font_family = "Inter Display Medium";

          position = "0, 30";
          halign = "center";
          valign = "bottom";
        }

      ];
    };
  };
}
