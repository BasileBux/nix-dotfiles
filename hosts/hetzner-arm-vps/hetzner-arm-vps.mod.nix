{ lib, inputs, ... }:
{
  flake.nixosConfigurations.hetzner-arm-vps = (import ../../lib/mkHost.nix { inherit inputs lib; }) {
    hostName = "hetzner-arm-vps";
    system = "aarch64-linux";
    homeModules = [
      inputs.self.homeModules.cli
    ];
    settings = {
      username = "eugene";
      hostname = "hetzner-arm-vps";
      desktop = false;
      accentColor = "#f57df3";
      nixosVersion = "24.11";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    extraModules = [
      inputs.self.nixosModules.hetzner
      inputs.disko.nixosModules.disko
      ./disko-config.nix
      ./remote-nvim.nix
    ];
  };
}
