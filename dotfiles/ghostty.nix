{
  settings,
  ...
}:

{
  programs.ghostty = {
    enable = true;

    enableZshIntegration = true;
    settings = {
      cursor-style = "block";
      shell-integration = "zsh";
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;

      # JetBrainsMono NF, Google Sans Code, Berkeley Mono
      font-family = "Berkeley Mono";

      font-size = 13;
      font-feature = "-calt";
      working-directory = "home";
      window-inherit-working-directory = false;

      # rose-pine, Abernathy, deep, tokyonight
      # theme = "custom";
      theme = "cyberdream";
      background-opacity = 0.8;

      window-padding-x = "3,3";
      window-padding-y = "4,0";

      keybind = [
        "ctrl+shift+1=increase_font_size:5"
        "ctrl+shift+.=reset_font_size"
      ];

      custom-shader = [
        "${settings.configPath}/dotfiles/misc/ghostty-cursor-warp.glsl"
      ];
    };
  };
}
