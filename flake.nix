{
  description = "Main flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs_stable.url = "github:nixos/nixpkgs?ref=nixos-26.05";
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
      pkgs_stable = import inputs.nixpkgs_stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      mkSystem =
        name: cfg:
        let
          settings = cfg.settings or { };

          secretsPath = "${settings.configPath}/secrets.nix";
          secretsExists = builtins.pathExists secretsPath;
          secrets = if secretsExists then import secretsPath else { };

          commonModules = name: [
            ./hosts/default.nix
            ./hosts/${name}/default.nix
            ./hosts/${name}/hardware-configuration.nix

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
        nixpkgs.lib.nixosSystem {
          system = cfg.system or "x86_64-linux";
          modules = (commonModules name) ++ (cfg.modules or [ ]);
          specialArgs = {
            inherit
              inputs
              settings
              secrets
              pkgs_stable
              ;
          };
        };

      systems = {
        asus-g14 =
          let
            settings = rec {
              username = "basileb";
              configPath = "/home/${username}/nixos";
              machine = "asus-g14";
              desktop = true;
              nixosVersion = "25.05"; # DO NOT CHANGE THIS EVER
            };
          in
          {
            inherit settings;
            modules = [
              ./hosts/desktop.nix
              inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
            ];
          };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs mkSystem systems;
    };
}
