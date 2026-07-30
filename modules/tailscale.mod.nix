{ self, ... }: {
  commonModules.tailscale = { ... }: {
    services.tailscale.enable = true;
  };
}
