{
  # Register as a NixOS module so that my.settings is available in nixosSystem
  config.flake.module.settings = {
    nixos = { config, lib, ... }: {
      options.my.settings = lib.mkOption {
        type = lib.types.submodule {
          options = {
            username = lib.mkOption { type = lib.types.str; };
            hostname = lib.mkOption { type = lib.types.str; };
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = "NixOS compatibility state version; not the running release.";
            };
            homeStateVersion = lib.mkOption {
              type = lib.types.str;
              default = config.my.settings.stateVersion;
              description = "Home Manager compatibility state version.";
            };
            gitName = lib.mkOption {
              type = lib.types.str;
              default = "BasileBux";
            };
            gitEmail = lib.mkOption {
              type = lib.types.str;
              default = "basile.buxtorf@ik.me";
            };
          };
        };
      };
    };
  };
}
