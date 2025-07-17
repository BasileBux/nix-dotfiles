{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;

    enableZshIntegration = true;
    settings = {
      cursor-style = "block";
      # shell-integration = "zsh";
      shell-integration-features = "no-cursor";
      mouse-hide-while-typing = true;

      font-family = "JetBrainsMono NF";
      font-style-italic = "Medium";

      font-size = 14;
      font-feature = "-calt";

      # rose-pine, Abernathy, deep, tokyonight
      theme = "custom";
      background-opacity = 0.8;

      window-padding-x = "3,3";
      window-padding-y = "4,0";

      keybind =
        [ "ctrl+shift+1=increase_font_size:5" "ctrl+shift+.=reset_font_size" ];
    };
    themes = {
      custom = {
	palette = [
	  "0=#000000"
	  "1=#FD788B"
	  "2=#20FF4F"
	  "3=#F4CC67"
	  "4=#68A9FF"
	  "5=#F970CD"
	  "6=#39FFE2"
	  "7=#ffffff"
	  "8=#525252"
	  "9=#FDB0BA"
	  "10=#25BA58"
	  "11=#FFCA14"
	  "12=#8CDAFF"
	  "13=#FE97E1"
	  "14=#A5FFFA"
	  "15=#d4ccb9"
	];

	background = "#0f0f0f";
	foreground = "#CAD3F5";
	cursor-color = "#CAD3F5";
	cursor-text = "#000000";
	selection-background = "#F4DBD6";
	selection-foreground = "#24273A";
      };
    };
  };
}
