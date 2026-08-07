{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qq = {
      url = "github:BasileBux/qq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    helium.url = "github:amaanq/helium-flake";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "";
      inputs.systems.follows = "systems";
    };

    systems.url = "github:nix-systems/default";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      {
        lib,
        self,
        inputs,
        ...
      }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = builtins.filter (lib.strings.hasSuffix ".mod.nix") (
          lib.filesystem.listFilesRecursive ./.
        );

        flake.lib = import ./lib inputs.nixpkgs.lib;

        # nixosConfigurations are defined by host .mod.nix files via mkHost
      }
    );
}
