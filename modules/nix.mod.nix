{ self, ... }: {
  flake.nixosModules.default = self.nixosModules.nix;
  flake.nixosModules.nix = { ... }: {
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
