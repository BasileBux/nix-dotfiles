{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.radicle;
  flake.nixosModules.radicle = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      radicle-node
      radicle-desktop
    ];
  };
}
