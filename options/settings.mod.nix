{ lib, ... }: {
  # Flake-parts level option declaration (for self-referential host .mod.nix files)
  options.my.settings = lib.mkOption {
    type = lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "The primary username for this system";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "The hostname for this machine";
        };
        nixosVersion = lib.mkOption {
          type = lib.types.str;
          description = "The NixOS state version. DO NOT CHANGE THIS EVER";
        };
        gitName = lib.mkOption {
          type = lib.types.str;
          default = "BasileBux";
          description = "Git and Jujutsu user name";
        };
        gitEmail = lib.mkOption {
          type = lib.types.str;
          default = "basile.buxtorf@ik.me";
          description = "Git and Jujutsu user email";
        };
      };
    };
    description = "Per-host settings validated by the module system.";
  };

  # Also register as a NixOS module so that my.settings is available in nixosSystem
  config.flake.nixosModules.settings = { lib, ... }: {
    options.my.settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          username = lib.mkOption { type = lib.types.str; };
          hostname = lib.mkOption { type = lib.types.str; };
          nixosVersion = lib.mkOption { type = lib.types.str; };
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
}
