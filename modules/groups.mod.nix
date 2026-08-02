{ self, ... }: {
  flake.nixosModules.default.imports = [
    self.nixosModules.nix
    self.nixosModules.users
    self.nixosModules.security
    self.nixosModules.ssh-server
    self.nixosModules.tailscale
    self.nixosModules.environment
    self.nixosModules.core
    self.nixosModules.localisation
    self.nixosModules.settings
  ];

  flake.homeModules.default.imports = [
    self.homeModules.zsh
    self.homeModules.neovim
    self.homeModules.vcs
  ];

  flake.homeModules.editor.imports = [
    self.homeModules.neovim
  ];

  flake.homeModules.cli.imports = [
    self.homeModules.zsh
    self.homeModules.tmux
    self.homeModules.vcs
    self.homeModules.fastfetch
  ];

  flake.homeModules.terminal.imports = [
    self.homeModules.ghostty
    self.homeModules.kitty
  ];

  flake.homeModules.desktop.imports = [
    self.homeModules.hyprland
    self.homeModules.quickshell
  ];

  flake.homeModules.gui.imports = [
    self.homeModules.theming
    self.homeModules.mime-apps
    self.homeModules.nemo
    self.homeModules.vscode
    self.homeModules.browser
  ];
}
