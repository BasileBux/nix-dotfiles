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

      hostname = lib.mkOption {
        type = lib.types.str;
        description = "The hostname for this machine. If not set, defaults to \${username}-\${machine}";
        default = "${config.username}-${config.machine}";
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

      accentColor = lib.mkOption {
        type = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
        default = "#fb8b1e";
        description = "Main accent color for prompts/theming, as #RRGGBB";
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

  hardwarePath = ../hosts/${name}/hardware-configuration.nix;

  commonModules = [
    ../hosts/default.nix
    ../hosts/${name}/default.nix

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

  optionalModules =
    lib.optional (builtins.pathExists hardwarePath) hardwarePath
    ++ lib.optional settings.desktop ../hosts/profiles/desktop.nix;
in
lib.nixosSystem {
  system = cfg.system or "x86_64-linux";
  modules = commonModules ++ optionalModules ++ (cfg.modules or [ ]);
  specialArgs = {
    inherit
      inputs
      settings
      secrets
      ;
  };
}
