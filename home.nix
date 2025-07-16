{ config, pkgs, ... }:

{
  imports = [
    ./dotfiles/ghostty.nix
  ];

  home.username = "basileb";
  home.homeDirectory = "/home/basileb";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
