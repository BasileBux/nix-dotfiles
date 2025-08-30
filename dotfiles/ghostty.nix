{ config, pkgs, colors, ... }:

{
  programs.ghostty = {
    enable = true;

    enableZshIntegration = true;
    settings = {
      cursor-style = "block";
      shell-integration = "zsh";
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;

      font-family = "JetBrainsMono NF";
      font-style-italic = "Medium";

      font-size = 13;
      font-feature = "-calt";

      # rose-pine, Abernathy, deep, tokyonight
      # theme = "custom";
      theme = "cyberdream";
      background-opacity = 0.8;

      window-padding-x = "3,3";
      window-padding-y = "4,0";

      keybind =
        [ "ctrl+shift+1=increase_font_size:5" "ctrl+shift+.=reset_font_size" ];

      custom-shader = [
        # "/home/basileb/tmp/ghostty-shaders/bloom.glsl"
      ];
    };
    themes = {
      custom = {
        palette = [
          "0=${colors.terminal.col0}"
          "1=${colors.terminal.col1}"
          "2=${colors.terminal.col2}"
          "3=${colors.terminal.col3}"
          "4=${colors.terminal.col4}"
          "5=${colors.terminal.col5}"
          "6=${colors.terminal.col6}"
          "7=${colors.terminal.col7}"
          "8=${colors.terminal.col8}"
          "9=${colors.terminal.col9}"
          "10=${colors.terminal.col10}"
          "11=${colors.terminal.col11}"
          "12=${colors.terminal.col12}"
          "13=${colors.terminal.col13}"
          "14=${colors.terminal.col14}"
          "15=${colors.terminal.col15}"
        ];

        background = "${colors.terminal.background}";
        foreground = "${colors.terminal.foreground}";
        cursor-color = "${colors.terminal.cursor}";
        cursor-text = "${colors.terminal.cursorText}";
        selection-background = "${colors.terminal.selectionBackground}";
        selection-foreground = "${colors.terminal.selectionForeground}";
      };

      cyberdream = {
        palette = [
          "0=#16181a"
          "1=#ff6e5e"
          "2=#5eff6c"
          "3=#f1ff5e"
          "4=#5ea1ff"
          "5=#bd5eff"
          "6=#5ef1ff"
          "7=#ffffff"
          "8=#3c4048"
          "9=#ff6e5e"
          "10=#5eff6c"
          "11=#f1ff5e"
          "12=#5ea1ff"
          "13=#bd5eff"
          "14=#5ef1ff"
          "15=#ffffff"
        ];
        # true background color is #16181a, but neovim won't render a background if the theme has the same background as the terminal
        background = "#16181b"; 
        foreground = "#ffffff";
        cursor-color = "#ffffff";
        cursor-text = "#16181a";
        selection-background = "#3c4048";
        selection-foreground = "#ffffff";
      };
    };
  };
}
