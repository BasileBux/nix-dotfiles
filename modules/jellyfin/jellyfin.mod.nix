# Owns the shared "media" group; other consumers (e.g. a host-local
# qBittorrent) join via users.users.<name>.extraGroups = [ "media" ].
{ self, ... }:
{
  flake.module.jellyfin = {
    imports = [ self.flakeModules.services ];
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

          upstreamPort = lib.mkOption {
            type = lib.types.port;
            default = 8096;
            description = "Existing Jellyfin HTTP listener port, configured separately in Jellyfin. This option only selects the proxy target; it does not configure Jellyfin networking.";
          };
        };

        config = lib.mkIf cfg.enable {
          services.jellyfin.enable = true;

          users.groups.media = { };
          users.users.jellyfin.extraGroups = [ "media" ];

          my.services.ports.jellyfin = cfg.upstreamPort;
          my.tailscale.serve.jellyfin.port = cfg.upstreamPort;
        };
      };
  };
}
