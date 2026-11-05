{ self, ... }: {
  flake.module.base.imports = with self.flakeModules; [
    nix
    system-defaults
    users
    settings
    services
    secrets
    security
    ssh-client
    xdg
  ];

  flake.module.personal.imports = with self.flakeModules; [
    base
    base-tools
    vcs
    nushell
    neovim
  ];

  # Compatibility aggregate for existing consumers.
  flake.module.default.imports = [ self.flakeModules.personal ];

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
