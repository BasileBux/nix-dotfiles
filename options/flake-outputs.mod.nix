{ config, lib, ... }: {
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    description = "Home-manager modules registered by .mod.nix files.";
  };

  options.commonModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    description = "Modules shared across all NixOS hosts. Automatically merged into flake.nixosModules.";
  };

  config.flake.nixosModules.default = lib.mkMerge (builtins.attrValues config.commonModules);
}
