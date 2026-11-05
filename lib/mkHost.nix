{
  inputs,
  lib,
  nixosSystem ? inputs.nixpkgs.lib.nixosSystem,
}:
{
  system ? "x86_64-linux",
  settings,
  modules ? [ ], # unified { nixos, home } modules (from flakeModules)
  nixosModules ? [ ], # raw NixOS modules for host-specific config / overrides
  homeModules ? [ ], # additional raw Home Manager modules
  # Optional secret consumers skip keyless hosts; required consumers assert.
  ageIdentityPaths ? [ ],
}:
let
  hardwarePath = ../hosts/${settings.hostname}/hardware-configuration.nix;

  # Extract nixos and home parts from unified modules
  unifiedNixos = map (m: {
    key = "unified:nixos:${m._name}";
    imports = [ m.nixos ];
  }) modules;
  unifiedHome = map (m: {
    key = "unified:home:${m._name}";
    imports = [ m.home ];
  }) modules;
in
nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.self.nixosModules.base
    inputs.self.nixosModules.secrets
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.${settings.username} = { osConfig, ... }: {
        imports = [
          inputs.self.homeModules.base
          inputs.self.homeModules.secrets
        ]
        ++ homeModules
        ++ unifiedHome;
        home.stateVersion = osConfig.my.settings.homeStateVersion;
      };
    }
    ({ config, ... }: {
      networking.hostName = config.my.settings.hostname;
      system.stateVersion = config.my.settings.stateVersion;
      my.settings = settings;
      age.identityPaths = ageIdentityPaths;
    })
  ]
  ++ unifiedNixos
  ++ nixosModules
  ++ [ hardwarePath ];
}
