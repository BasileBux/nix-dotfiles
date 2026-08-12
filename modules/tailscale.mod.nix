{
  flake.module.tailscale = {
    nixos = {
      services.tailscale.enable = true;
    };
  };
}
