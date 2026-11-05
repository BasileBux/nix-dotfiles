{
  inputs,
  lib,
  nixosSystem ? inputs.nixpkgs.lib.nixosSystem,
}:
{
  # Host name; also selects hosts/<name>/{identity,hardware-configuration}.nix.
  name,
  # Fleet-visible host data. Omit to use hosts/<name>/identity.nix.
  identity ? null,
  system ? "x86_64-linux",
  stateVersion,
  homeStateVersion ? stateVersion,
  modules ? [ ], # unified { nixos, home } modules (from flakeModules)
  nixosModules ? [ ], # raw NixOS modules for host-specific config / overrides
  homeModules ? [ ], # additional raw Home Manager modules
  # Optional secret consumers skip keyless hosts; required consumers assert.
  ageIdentityPaths ? [ ],
  # Unlock secrets with <homeDirectory>/.ssh/<name>. Defaults to "this host
  # declares an age recipient key", so a keyless host stays keyless.
  useHostIdentity ? null,
}:
let
  fleet = import ../fleet.nix;

  hostIdentity =
    if identity == null then
      import (../hosts + "/${name}/identity.nix")
    else if builtins.isPath identity then
      import identity
    else
      identity;

  username =
    if (hostIdentity.username or null) == null then fleet.defaults.username else hostIdentity.username;

  settings = {
    hostname = name;
    inherit username stateVersion homeStateVersion;
  };

  unlockWithHostIdentity = if useHostIdentity == null then hostIdentity ? key else useHostIdentity;

  hardwarePath = ../hosts/${name}/hardware-configuration.nix;

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
    ({ config, ... }: {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.${config.my.settings.username} = { osConfig, ... }: {
        imports = [
          inputs.self.homeModules.base
          inputs.self.homeModules.secrets
        ]
        ++ homeModules
        ++ unifiedHome;
        home.stateVersion = osConfig.my.settings.homeStateVersion;
      };
    })
    ({ config, ... }: {
      networking.hostName = config.my.settings.hostname;
      system.stateVersion = config.my.settings.stateVersion;
      my.settings = settings;
      age.identityPaths =
        ageIdentityPaths
        ++ lib.optional unlockWithHostIdentity "${config.my.settings.homeDirectory}/.ssh/${config.networking.hostName}";
    })
  ]
  ++ unifiedNixos
  ++ nixosModules
  ++ [ hardwarePath ];
}
