{ self, lib, ... }: {
  flake.homeModules.ghostty = { config, settings, ... }: {
    imports = lib.optionals (settings.desktop != null) [ ];
    config = lib.mkIf (settings.desktop != null) {
      programs.ghostty = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          cursor-style = "block";
          shell-integration = "zsh";
          shell-integration-features = "no-cursor";
          mouse-hide-while-typing = true;
          font-family = "TX-02";
          font-size = 12;
          font-feature = "-calt";
          working-directory = "home";
          window-inherit-working-directory = false;
          theme = "Deep";
          background-opacity = 0.8;
          window-padding-x = "3,3";
          window-padding-y = "4,0";
          keybind = [
            "ctrl+shift+1=increase_font_size:5"
            "ctrl+shift+.=reset_font_size"
          ];
          custom-shader = [
            (toString ../dotfiles/misc/ghostty-cursor-warp.glsl)
          ];
        };
      };
    };
  };
}
