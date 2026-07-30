{ self, ... }: {
  commonModules.core = { ... }: {
    networking.networkmanager.enable = true;
    time.timeZone = "Europe/Amsterdam";
  };
}
