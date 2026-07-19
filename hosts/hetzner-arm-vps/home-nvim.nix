{
  settings,
  pkgs,
  ...
}:

{
  imports = [
    ../../dotfiles/tmux.nix
    ../../dotfiles/zsh/zsh.nix
  ];

  home.username = "nvim";
  home.homeDirectory = "/home/nvim";

  home.stateVersion = "${settings.nixosVersion}";
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    neovim-unwrapped
    ripgrep
    fd
    fzf
    gcc
    tree-sitter
    imagemagick
    ghostscript

    # LSPs and formatters
    basedpyright
    cmake-language-server
    stylua
    clang-tools
    gopls
    gotools
    ltex-ls
    lua-language-server
    nil
    nixfmt
    prettier
    kdePackages.qtdeclarative
    tinymist
    typescript-language-server
    typstyle
    marksman
    bash-language-server
  ];

  home.sessionVariables.NVIM_UNDODIR = "/home/nvim/.local/share/nvim/undo";

  # Copy into store (no mkOutOfStoreSymlink) so nvim user can read it
  xdg.configFile."nvim".source = "${settings.configPath}/dotfiles/nvim";
}
