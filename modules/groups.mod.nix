{ self, ... }: {

  flake.module.default.imports = with self.flakeModules; [
    nix
    users
    settings

    security
    ssh-client
    xdg

    base-tools

    vcs
    nushell
    neovim
  ];

  # Desktop aggregate; pulls in all GUI modules
  flake.module.desktop.imports = with self.flakeModules; [
    audio
    bluetooth
    desktop-apps
    fonts
    hyprland
    plymouth
    polkit
    quickshell
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
