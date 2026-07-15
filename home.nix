{
  settings,
  lib,
  ...
}:

{
  imports = [
    ./dotfiles/tmux.nix
    ./dotfiles/zsh/zsh.nix
    ./dotfiles/neovim.nix
  ]
  ++ lib.optionals (settings.desktop) [
    ./dotfiles/ghostty.nix
    ./dotfiles/zen.nix
    ./dotfiles/fastfetch/fastfetch.nix
    ./dotfiles/hypr/hyprland.nix
    ./dotfiles/hypr/hypridle.nix
    ./dotfiles/theming.nix
    ./dotfiles/quickshell.nix
    ./dotfiles/vscode.nix
    ./dotfiles/kitty.nix
    ./dotfiles/mime-apps.nix
    ./dotfiles/nemo.nix
  ];

  home.username = "${settings.username}";
  home.homeDirectory = "/home/${settings.username}";

  home.stateVersion = "${settings.nixosVersion}";
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = {
      user = {
        name = "${settings.gitName}";
        email = "${settings.gitEmail}";
        signingkey = "/home/${settings.username}/.ssh/id_ed25519.pub";
      };
      core.editor = "nvim";
      alias.pushall = "!git push origin && git push gh main";
    };

    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "${settings.gitName}";
        email = "${settings.gitEmail}";
      };
      ui = {
        default-command = "log";
        editor = "nvim";
        merge-editor = "meld";
      };
      signing = {
        behavior = "own";
        backend = "ssh";
        key = "/home/${settings.username}/.ssh/id_ed25519.pub";
      };
      git = {
        sign-on-push = true;
      };
    };
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 2w --keep 10 --optimise";
      dates = "daily";
    };
    flake = "${settings.configPath}#${settings.machine}";
  };
}
