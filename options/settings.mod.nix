let
  fleet = import ../fleet.nix;
in
{
  # Register as a NixOS module so that my.settings is available in nixosSystem
  config.flake.module.settings = {
    nixos = { config, lib, ... }: {
      options.my.settings = lib.mkOption {
        type = lib.types.submodule {
          options = {
            username = lib.mkOption {
              type = lib.types.str;
              default = fleet.defaults.username;
              description = "Primary login user, inherited from fleet defaults and the host's identity.nix exception.";
            };
            homeDirectory = lib.mkOption {
              type = lib.types.str;
              default = "/home/${config.my.settings.username}";
              description = "Primary user's home, also used to locate the optional host identity.";
            };
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
              default = fleet.defaults.gitName;
            };
            gitEmail = lib.mkOption {
              type = lib.types.str;
              default = fleet.defaults.gitEmail;
            };
          };
        };
      };
    };
  };
}
