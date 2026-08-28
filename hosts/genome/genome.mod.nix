{ lib, inputs, ... }:
{
  flake.nixosConfigurations.genome =
    (import ../../lib/mkHost.nix {
      inherit inputs lib;
      nixosSystem = inputs.nixos-raspberrypi.lib.nixosSystem;
    })
      rec {

        settings = {
          username = "basileb";
          hostname = "genome";
          nixosVersion = "26.05";
          gitName = "BasileBux";
          gitEmail = "basile.buxtorf@ik.me";
        };
        system = "aarch64-linux";
        ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];

        modules = with inputs.self.flakeModules; [
          slop
          ssh-server
          tmux
          tailscale
          vaultwarden
          linkwarden
          jellyfin
          upsnap
        ];

        nixosModules = [
          ./extra-config.nix
          ./services.nix
          ./qbittorrent.nix
          {
            my.nushell.accentColor = "#fb1e2e";
            my.ssh.enableFail2ban = false;
          }
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
        ];
      };
}
