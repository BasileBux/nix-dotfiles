{ inputs, lib }:
{
  hostName,
  system ? "x86_64-linux",
  settings,
  modules ? [ ], # unified { nixos, home } modules (from flakeModules)
  nixosModules ? [ ], # raw NixOS modules for host-specific config / overrides
  homeModules ? [ ], # additional raw Home Manager modules
  # Secrets opt-in: if you don't give any identity paths, you get no module secrets
  # at all and everything consuming them is disabled.
  ageIdentityPaths ? [ ],
}:
let
  hardwarePath = ../hosts/${hostName}/hardware-configuration.nix;

  # Extract nixos and home parts from unified modules
  unifiedNixos = map (m: m.nixos or { }) modules;
  unifiedHome = map (m: m.home or { }) modules;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs;
    settings = settings;
  };
  modules = [
    inputs.self.nixosModules.default
    inputs.self.nixosModules.secrets
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        settings = settings;
      };
      home-manager.users.${settings.username} = {
        imports = [
          inputs.self.homeModules.default
          inputs.self.homeModules.secrets
        ]
        ++ homeModules
        ++ unifiedHome;
        home.stateVersion = settings.nixosVersion;
      };
    }
    {
      networking.hostName = settings.hostname;
      system.stateVersion = settings.nixosVersion;
      my.settings = settings;
      age.identityPaths = ageIdentityPaths;
    }
  ]
  ++ unifiedNixos
  ++ nixosModules
  ++ lib.optional (builtins.pathExists hardwarePath) hardwarePath;
}
