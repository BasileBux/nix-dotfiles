{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.gvfs;
  flake.nixosModules.gvfs = { ... }: {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
  };
}
