{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  imports = [
    ./dotfiles/ghostty.nix
    ./dotfiles/zen.nix
    ./dotfiles/fastfetch/fastfetch.nix
    ./dotfiles/tmux.nix
    ./dotfiles/waybar/waybar.nix
    ./dotfiles/zsh/zsh.nix
    ./dotfiles/hypr/hyprland.nix
    ./dotfiles/hypr/hyprlock.nix
    ./dotfiles/hypr/hypridle.nix
    ./dotfiles/wlogout/wlogout.nix
    ./dotfiles/theming.nix
    ./dotfiles/wofi.nix
    ./dotfiles/neovim.nix
  ];

  home.username = "${settings.username}";
  home.homeDirectory = "/home/${settings.username}";

  home.stateVersion = "${settings.nixosVersion}";

  programs.home-manager.enable = true;
}
