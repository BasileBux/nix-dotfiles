{ ... }: {
  flake.module.plymouth = {
    nixos = {
      boot = {
        plymouth.enable = true;
        consoleLogLevel = 0;
        kernelParams = [
          "quiet"
          "udev.log_priority=3"
        ];
      };
    };
  };
}
