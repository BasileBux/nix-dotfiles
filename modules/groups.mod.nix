{ self, ... }: {

  flake.module.default.imports = with self.flakeModules; [
    nix
    users
    security
    ssh-server
    base-tools
    settings
    xdg
    vcs
    nushell
    neovim
    tmux
  ];

  # Desktop aggregate — pulls in all GUI modules
  flake.module.desktop.imports = with self.flakeModules; [
    audio
    bluetooth
    desktop-apps
    fonts
    hyprland
    plymouth
    polkit
    quickshell
    radicle
    theming
    kitty
    ghostty
    nemo
    vscode
    browser
    video
    images
    pdf
  ];
}
