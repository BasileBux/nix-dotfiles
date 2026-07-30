{ self, ... }: {
  flake.homeModules.cli.imports = [
    self.homeModules.zsh
    self.homeModules.tmux
    self.homeModules.vcs
    self.homeModules.nh
    self.homeModules.fastfetch
  ];

  flake.homeModules.editor.imports = [
    self.homeModules.neovim
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
    self.homeModules.browser
    self.homeModules.theming
    self.homeModules.mime-apps
    self.homeModules.nemo
    self.homeModules.vscode
  ];
}
