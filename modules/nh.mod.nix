{ self, ... }: {
  flake.homeModules.nh = { config, settings, ... }: {
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
