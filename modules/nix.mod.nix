{ self, ... }: {
  flake.nixosModules.nix = { settings, ... }: {

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 2w --keep 10 --optimise";
        dates = "daily";
      };
      flake = ".#${settings.hostname}";
    };
  };
}
