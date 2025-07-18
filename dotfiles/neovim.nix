{ lib, config, pkgs, inputs, settings, ... }:

{
  home.packages = with pkgs; [ ripgrep fd fzf gcc cargo rustc ];
  programs.neovim.enable = true;
  xdg.configFile = {
    "nvim" = {
      source = "${settings.configPath}/dotfiles/nvim";
      recursive = true;
    };
  };
}
