{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.polkit;
  flake.nixosModules.polkit = { ... }: {
    security.polkit = {
      enable = true;
      enablePkexecWrapper = true;
    };
  };
}
