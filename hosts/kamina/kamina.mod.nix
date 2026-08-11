{ lib, inputs, ... }:
{
  flake.nixosConfigurations.kamina = (import ../../lib/mkHost.nix { inherit inputs lib; }) rec {
    settings = {
      username = "basileb";
      hostname = "kamina";
      nixosVersion = "26.05";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    hostName = settings.hostname;
    system = "x86_64-linux";

    homeModules = [ ];
    ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];
    extraModules = [
      {
        my.nushell.accentColor = "#fbe61e"; # Other possible options: #1eebfb #8b1efb #1efb8b
      }
      inputs.self.nixosModules.smb
      inputs.self.nixosModules.tailscale
    ];
  };
}
