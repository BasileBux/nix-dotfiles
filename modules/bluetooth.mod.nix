{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.bluetooth;
  flake.nixosModules.bluetooth = { ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
