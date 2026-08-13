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
    ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];

    modules = with inputs.self.flakeModules; [
      smb
      tailscale
      slop
    ];
    nixosModules = [
      ./extra-config.nix
      {
        my.nushell.accentColor = "#fbe61e"; # Other possible options: #1eebfb #8b1efb #1efb8b
        my.ssh.extraAuthorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3JtMPAdhCamdxtzssUutjNaCyGtsUVltvtLakwuPze"
        ];
      }
    ];
  };
}
