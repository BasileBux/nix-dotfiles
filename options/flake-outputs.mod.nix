{ lib, config, ... }:
let
  unifiedModuleType = lib.types.submodule ({ config, ... }: {
    options = {
      nixos = lib.mkOption {
        type = lib.types.deferredModule;
        default = { };
        description = "NixOS module part.";
      };
      home = lib.mkOption {
        type = lib.types.deferredModule;
        default = { };
        description = "Home Manager module part.";
      };
      imports = lib.mkOption {
        type = lib.types.listOf unifiedModuleType;
        default = [ ];
        description = "List of unified modules whose nixos and home parts are imported.";
      };
    };
    config = {
      nixos.imports = map (m: m.nixos) config.imports;
      home.imports = map (m: m.home) config.imports;
    };
  });
in
{
  options.flake.module = lib.mkOption {
    type = lib.types.lazyAttrsOf unifiedModuleType;
    default = { };
    description = "Unified module bundling a NixOS module and/or a Home Manager module.";
  };

  # Expose unified modules as flake output so hosts can do
  #   modules = with inputs.self.flakeModules; [ smb tailscale ]
  config.flake.flakeModules = config.flake.module;

  # Auto-derive nixosModules and homeModules so external consumers
  # can still use inputs.self.nixosModules.xxx and inputs.self.homeModules.xxx
  config.flake.nixosModules = lib.mkMerge [
    (builtins.mapAttrs (_: v: v.nixos) config.flake.module)
  ];

  config.flake.homeModules = lib.mkMerge [
    (builtins.mapAttrs (_: v: v.home) config.flake.module)
  ];
}
