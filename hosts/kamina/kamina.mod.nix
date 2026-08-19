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
    system = "x86_64-linux";
    ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];

    modules = with inputs.self.flakeModules; [
      smb
      tailscale
      ssh-server
      tmux
      slop
      t3
    ];
    nixosModules = [
      ./extra-config.nix
      {
        my.nushell.accentColor = "#fbe61e"; # Other possible options: #1eebfb #8b1efb #1efb8b
        my.ssh.extraAuthorizedKeys = [
          # ipad / iphone through tailscale (termius)
          "from=\"100.122.103.5,100.84.142.57\"  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3JtMPAdhCamdxtzssUutjNaCyGtsUVltvtLakwuPze"
          # upsnap on the raspberry pi through tailscale and eth0/wlan0 LAN
          "from=\"192.168.1.191,192.168.1.190,100.80.171.121\"  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDUZ/0p/7j6gcvZS1Cm8f2PP2dzrNN5WSxvMJQaPLzFv upsnap@raspberrypi"
        ];
        my.t3Host = "100.100.86.25";
      }
    ];
  };
}
