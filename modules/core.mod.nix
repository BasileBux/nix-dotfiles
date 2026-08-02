{ self, ... }: {
  flake.nixosModules.core = { ... }: {
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/Amsterdam";
  };
}
