{ self, ... }: {
  flake.nixosModules.localisation = { ... }: {
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
  };
}
