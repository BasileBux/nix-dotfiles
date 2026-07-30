{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.plymouth;
  flake.nixosModules.plymouth = { ... }: {
    boot = {
      plymouth.enable = true;
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "loglevel=3"
        "udev.log_priority=3"
      ];
    };
  };
}
