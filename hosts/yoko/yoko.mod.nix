{ lib, inputs, ... }:
{
  flake.nixosConfigurations.yoko = (import ../../lib/mkHost.nix { inherit inputs lib; }) rec {

    settings = {
      username = "eugene";
      hostname = "yoko";
      nixosVersion = "24.11";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    hostName = settings.hostname;
    system = "aarch64-linux";

    homeModules = [ ];
    ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];
    extraModules = [
      {
        my.nushell.accentColor = "#fb1e8b";
      }
      ./hetzner-config.nix
      inputs.disko.nixosModules.disko
      ./disko-config.nix
      ./remote-nvim.nix
    ];
  };
}
