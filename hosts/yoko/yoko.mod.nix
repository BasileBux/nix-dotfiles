{ lib, inputs, ... }:
{
  flake.nixosConfigurations.yoko = (import ../../lib/mkHost.nix { inherit inputs lib; }) {
    name = "yoko";
    stateVersion = "24.11";
    system = "aarch64-linux";

    modules = with inputs.self.flakeModules; [
      personal
      slop
      ssh-server
      tmux
    ];
    nixosModules = [
      {
        my.nushell.accentColor = "#fb1e8b";
        services.fail2ban.maxretry = 3;
        services.fail2ban.bantime-increment.enable = true;
      }
      ./hetzner-config.nix
      inputs.disko.nixosModules.disko
      ./disko-config.nix
    ];
  };
}
