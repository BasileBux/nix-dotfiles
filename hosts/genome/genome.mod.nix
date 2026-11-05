{ lib, inputs, ... }:
{
  flake.nixosConfigurations.genome =
    (import ../../lib/mkHost.nix {
      inherit inputs lib;
      nixosSystem = inputs.nixos-raspberrypi.lib.nixosSystem;
    })
      {

        name = "genome";
        stateVersion = "26.05";
        system = "aarch64-linux";

        modules = with inputs.self.flakeModules; [
          personal
          slop
          ssh-server
          tmux
          tailscale
          vaultwarden
          linkwarden
          jellyfin
          upsnap
          simple-todo
          syncthing
          smb
        ];

        nixosModules = [
          ./extra-config.nix
          ./services.nix
          ./qbittorrent.nix
          ./downloads-export.nix
          {
            my.nushell.accentColor = "#fb1e2e";
            my.ssh.enableFail2ban = false;

            # Orgfiles: syncthing hub for the tailnet; hourly jj snapshots.
            # Mesh topology lives in fleet.nix, device IDs in hosts/*/identity.nix.
            my.syncthing.snapshot.repos = [ "orgfiles" ];
            my.smb = {
              host = "100.86.179.75";
              destination = "/media";
              credentials = "modules/smb/synology.age";
            };
          }
          inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
        ];
      };
}
