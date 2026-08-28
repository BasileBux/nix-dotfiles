# Owns the shared "media" group; other consumers (e.g. a host-local
# qBittorrent) join via users.users.<name>.extraGroups = [ "media" ].
{
  ...
}:
{
  flake.module.jellyfin = {
    nixos =
      { config, lib, ... }:
      let
        cfg = config.my.services.jellyfin;
      in
      {
        options.my.services.jellyfin = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable Jellyfin media server (served on the tailnet)";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 8096;
            description = "Loopback port for the web UI/API";
          };
        };

        config = lib.mkIf cfg.enable {
          services.jellyfin.enable = true;

          users.groups.media = { };
          users.users.jellyfin.extraGroups = [ "media" ];

          my.services.ports.jellyfin = cfg.port;
          my.tailscale.serve.jellyfin.port = cfg.port;
        };
      };
  };
}
