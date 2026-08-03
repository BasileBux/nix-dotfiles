{ ... }: {
  flake.nixosModules.nix = { pkgs, settings, ... }: {

    hardware.enableRedistributableFirmware = true;

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

    networking.networkmanager.enable = true;
    time.timeZone = "Europe/Amsterdam";

    nixpkgs.config.allowUnfree = true;
    nix.channel.enable = false;
    nix.package = pkgs.nixVersions.latest;
    nix.optimise.automatic = true;

    console = {
      font = "Lat2-Terminus16";
      earlySetup = true;
      useXkbConfig = true;
    };
    services.xserver.xkb = {
      layout = "us,ch";
      variant = ",fr";
      options = "grp:alt_space_toggle,ctrl:nocaps";
    };

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
