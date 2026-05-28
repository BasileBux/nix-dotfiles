{
  description = "Main flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs_stable.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    helium.url = "github:amaanq/helium-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      pkgs_stable = import inputs.nixpkgs_stable { # NOTE: Used for packages which are broken in unstable
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      settings = {
        username = "basileb";
        configPath = "/home/${settings.username}/nixos";
        machine = "asus-g14";
        swapAltSuper = false;
        nixosVersion = "25.05"; # DO NOT CHANGE THIS EVER
      };

      secretsPath = "${settings.configPath}/secrets.nix";
      secretsExists = builtins.pathExists secretsPath;
      secrets = if secretsExists then import secretsPath else { };

    in
    {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            settings
            secrets
            pkgs_stable
            ;
        };

        modules = [
          "${settings.configPath}/configuration.nix"
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
        ]
        ++ nixpkgs.lib.optionals (settings.machine == "asus-g14") [
          inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
        ];
      };
    };
}
