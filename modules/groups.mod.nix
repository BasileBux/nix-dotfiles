{ self, ... }: {

  flake.module.default.imports = with self.flakeModules; [
    nix
    users
    settings
    services
    tailscale-options
    syncthing-options

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
    nemo
    browser
    video
    images
    pdf
  ];
}
