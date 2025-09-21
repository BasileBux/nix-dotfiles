{ config, pkgs, colors, settings, ... }:

{
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;

    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
      mode = "no-cursor";
    };

    settings = {
      font_family = "JetBrainsMono NF";
      disable_ligatures = "always";

      font_size = 13;

      tab_bar_style = "powerline";
      tab_powerline_style = "round";

      background_opacity = 0.8;

      window_padding_width =  "3 4";

      cursor_shape = "block";
      cursor_shape_unfocused = "hollow";
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.4";

      # Scrollback.nvim plugin: github.com/mikesmithgh/kitty-scrollback.nvim
      allow_remote_control = "socket-only";
      listen_on = "unix:/tmp/kitty";
      action_alias = "kitty_scrollback_nvim kitten /home/basileb/.local/share/nvim/lazy/kitty-scrollback.nvim/python/kitty_scrollback_nvim.py";

      color0 = "#16181a";
      color1 = "#ff6e5e";
      color2 = "#5eff6c";
      color3 = "#f1ff5e";
      color4 = "#5ea1ff";
      color5 = "#bd5eff";
      color6 = "#5ef1ff";
      color7 = "#ffffff";
      color8 = "#3c4048";
      color9 = "#ff6e5e";
      color10 = "#5eff6c";
      color11 = "#f1ff5e";
      color12 = "#5ea1ff";
      color13 = "#bd5eff";
      color14 = "#5ef1ff";
      color15 = "#ffffff";
      # true background color is #16181a, but neovim won't render a background if the theme has the same background as the terminal
      background = "#16181b";
      foreground = "#ffffff";
      cursor-color = "#ffffff";
      cursor-text = "#16181a";
      selection-background = "#3c4048";
      selection-foreground = "#ffffff";
    };
    keybindings = {
      "ctrl+shift+." = "change_font_size all 0";
      "kitty_mod+h" = "kitty_scrollback_nvim";
    };
  };
}
