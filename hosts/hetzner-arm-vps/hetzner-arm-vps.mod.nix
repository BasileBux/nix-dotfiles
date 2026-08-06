{ lib, inputs, ... }:
{
  flake.nixosConfigurations.hetzner-arm-vps = (import ../../lib/mkHost.nix { inherit inputs lib; }) {
    hostName = "hetzner-arm-vps";
    system = "aarch64-linux";
    homeModules = [
      inputs.self.homeModules.default
    ];
    settings = {
      username = "eugene";
      hostname = "hetzner-arm-vps";
      nixosVersion = "24.11";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    extraModules = [
      { my.zsh.accentColor = "#f57df3"; }
      ./hetzner-config.nix
      inputs.disko.nixosModules.disko
      ./disko-config.nix
      ./remote-nvim.nix
    ];
  };
}
