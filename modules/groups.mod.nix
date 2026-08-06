{ self, ... }: {
  flake.nixosModules.default.imports = [
    self.nixosModules.nix
    self.nixosModules.users
    self.nixosModules.security
    self.nixosModules.ssh-server
    self.nixosModules.base-tools
    self.nixosModules.settings
    self.nixosModules.shell
    self.nixosModules.xdg
  ];

  flake.homeModules.default.imports = [
    self.homeModules.shell
    self.homeModules.vcs
    self.homeModules.xdg
  ];
}
