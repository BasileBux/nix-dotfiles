{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.upower;
  flake.nixosModules.upower = { ... }: {
    services.upower.enable = true;
  };
}
