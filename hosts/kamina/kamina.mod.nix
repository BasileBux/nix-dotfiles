{ lib, inputs, ... }:
{
  flake.nixosConfigurations.kamina = (import ../../lib/mkHost.nix { inherit inputs lib; }) rec {
    # TODO: Add key encryption key to entities.mod.nix
    settings = {
      username = "basileb";
      hostname = "kamina";
      nixosVersion = "26.05"; # WARN: check the version before rebuilding
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    hostName = settings.hostname;
    system = "x86_64-linux";

    homeModules = [ ];
    extraModules = [
      {
        my.nushell.accentColor = "#fbe61e"; # Other possible options: #1eebfb #8b1efb #1efb8b
        age.identityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];
      }
      inputs.self.nixosModules.smb
      inputs.self.nixosModules.tailscale
    ];
  };
}
