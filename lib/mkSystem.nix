{ inputs }:
let
  lib = inputs.nixpkgs.lib;

  settingsModule = { config, ... }: {
    options = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "The primary username for this system";
      };

      configPath = lib.mkOption {
        type = lib.types.str;
        description = "Absolute path to this NixOS configuration repository";
        default = "/home/${config.username}/nixos";
      };

      machine = lib.mkOption {
        type = lib.types.str;
        description = "The hostname / machine identifier (should match the name of the system in the flake)";
      };

      desktop = lib.mkOption {
        type = lib.types.bool;
        description = "Whether this machine is a desktop";
        default = false;
      };

      nixosVersion = lib.mkOption {
        type = lib.types.str;
        description = "The NixOS state version. DO NOT CHANGE THIS EVER";
      };
    };
  };

  validateSettings =
    settings:
    (lib.evalModules {
      modules = [
        settingsModule
        { config = settings; }
      ];
    }).config;

in
name: cfg:
let
  settings = validateSettings (cfg.settings or { });

  secretsPath = "${settings.configPath}/secrets.nix";
  secretsExists = builtins.pathExists secretsPath;
  secrets = if secretsExists then import secretsPath else { };

  commonModules = name: [
    ../hosts/default.nix
    ../hosts/${name}/default.nix
    ../hosts/${name}/hardware-configuration.nix

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.extraSpecialArgs = {
        inherit
          inputs
          settings
          secrets
          ;
      };
      home-manager.useGlobalPkgs = true;
    }
  ];
in
lib.nixosSystem {
  system = cfg.system or "x86_64-linux";
  modules = (commonModules name) ++ (cfg.modules or [ ]);
  specialArgs = {
    inherit
      inputs
      settings
      secrets
      ;
  };
}
