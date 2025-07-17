{ config, pkgs, inputs, settings, ... }:

{
  imports = [
    ./dotfiles/ghostty.nix
    ./dotfiles/zen.nix
    ./dotfiles/fastfetch/fastfetch.nix
    ./dotfiles/tmux.nix
    ./dotfiles/waybar/waybar.nix
    ./dotfiles/zsh/zsh.nix
  ];

  home.username = "${settings.username}";
  home.homeDirectory = "/home/${settings.username}";

  home.stateVersion = "${settings.nixosVersion}";

  programs.home-manager.enable = true;
}
