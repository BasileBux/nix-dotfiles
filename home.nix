{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  imports = [
    ./dotfiles/ghostty.nix
    ./dotfiles/zen.nix
    ./dotfiles/fastfetch/fastfetch.nix
    ./dotfiles/tmux.nix
    ./dotfiles/zsh/zsh.nix
    ./dotfiles/hypr/hyprland.nix
    ./dotfiles/hypr/hyprlock.nix
    ./dotfiles/hypr/hypridle.nix
    ./dotfiles/theming.nix
    ./dotfiles/quickshell.nix
    ./dotfiles/vscode.nix
    ./dotfiles/kitty.nix
  ];

  home.username = "${settings.username}";
  home.homeDirectory = "/home/${settings.username}";

  home.stateVersion = "${settings.nixosVersion}";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "BasileBux";
    userEmail = "basile.buxtorf@ik.me";

    signing = {
      format = "ssh";
      signByDefault = true;
    };

    extraConfig = {
      user.signingkey = "/home/${settings.username}/.ssh/id_ed25519.pub";
    };
  };
}
