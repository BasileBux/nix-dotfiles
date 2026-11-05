{ lib, config, ... }:
let
  unifiedModuleType = lib.types.submodule (
    { config, name, ... }: {
      options = {
        _name = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          default = name;
          internal = true;
        };
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
          # References must retain their identity, not be re-evaluated as submodules.
          type = lib.types.listOf (
            lib.types.addCheck lib.types.attrs (m: m ? _name && m ? nixos && m ? home)
          );
          default = [ ];
          description = "List of unified modules whose nixos and home parts are imported.";
        };
      };
      config = {
        nixos = {
          imports = map (m: {
            key = "unified:nixos:${m._name}";
            imports = [ m.nixos ];
          }) config.imports;
        };
        home = {
          imports = map (m: {
            key = "unified:home:${m._name}";
            imports = [ m.home ];
          }) config.imports;
        };
      };
    }
  );
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
    (builtins.mapAttrs (name: v: {
      key = "unified:nixos:${name}";
      imports = [ v.nixos ];
    }) config.flake.module)
  ];

  config.flake.homeModules = lib.mkMerge [
    (builtins.mapAttrs (name: v: {
      key = "unified:home:${name}";
      imports = [ v.home ];
    }) config.flake.module)
  ];
}
