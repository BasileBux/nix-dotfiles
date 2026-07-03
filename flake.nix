{
  description = "Main flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
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
      mkSystem = import ./lib/mkSystem.nix { inherit inputs; };

      systems = {
        asus-g14 = {
          settings = {
            username = "basileb";
            machine = "asus-g14";
            desktop = true;
            nixosVersion = "25.05"; # DO NOT CHANGE THIS EVER
            accentColor = "#fb8b1e";
          };
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
