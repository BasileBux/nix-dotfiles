{ ... }: {
  flake.module.radicle = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        radicle-node
        radicle-desktop
      ];
    };
  };
}
