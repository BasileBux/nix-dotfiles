{
  imports = [
    ./services/defaults.nix
    ./services/secrets.nix
    ./services/vaultwarden.nix
    ./services/linkwarden.nix
    ./services/jellyfin.nix
    ./services/qbittorrent.nix
    ./services/upsnap.nix
    ./services/tailscale-serve.nix
  ];
}
