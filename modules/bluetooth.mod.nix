{ self, pkgs, ... }: {
  flake.nixosModules.desktop = self.nixosModules.bluetooth;
  flake.nixosModules.bluetooth = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    environment.systemPackages = with pkgs; [
      blueman
    ];
  };
}
