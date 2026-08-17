{
  # Register as a NixOS module so that my.settings is available in nixosSystem
  config.flake.module.settings = {
    nixos = { lib, ... }: {
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
  };
}
