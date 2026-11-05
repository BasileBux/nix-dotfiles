{
  flake.module.nix.nixos = { pkgs, config, ... }: {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "cgroups"
        "pipe-operators"
      ];
      use-cgroups = true;
      use-xdg-base-directories = true;
      warn-dirty = false;
    };
    nixpkgs.config.allowUnfree = true;
    nix.channel.enable = false;
    nix.package = pkgs.nixVersions.latest;
    nix.optimise.automatic = true;
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 2w --keep 10 --optimise";
        dates = "daily";
      };
      flake = ".#${config.my.settings.hostname}";
    };
  };
}
