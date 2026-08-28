{
  ...
}:
{
  flake.module.upsnap = {
    nixos =
      {
        inputs,
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.my.services.upsnap;
        upsnap = pkgs.callPackage (inputs.self + "/packages/upsnap") { };
      in
      {
        options.my.services.upsnap = {
          enable = lib.mkEnableOption "UpSnap wake-on-LAN dashboard (served on the tailnet)";

          port = lib.mkOption {
            type = lib.types.port;
            default = 9090;
            description = "Loopback port for the web UI";
          };

          timeZone = lib.mkOption {
            type = lib.types.str;
            default = "Europe/Zurich";
            description = "TZ passed to UpSnap (schedule display)";
          };
        };

        config = lib.mkIf cfg.enable {
          users.users.upsnap = {
            isSystemUser = true;
            group = "upsnap";
          };
          users.groups.upsnap = { };

          systemd.services.upsnap = {
            description = "UpSnap — remote wake/release control";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];

            environment = {
              TZ = cfg.timeZone;
              UPSNAP_HTTP_LISTEN = "127.0.0.1:${toString cfg.port}";
              HOME = "/var/lib/upsnap";
            };

            path = [
              pkgs.openssh
              pkgs.nmap
              pkgs.curl
              pkgs.bash
            ];

            serviceConfig = {
              Type = "simple";
              User = "upsnap";
              Group = "upsnap";
              StateDirectory = "upsnap";
              WorkingDirectory = "/var/lib/upsnap";
              ExecStart = "${upsnap}/bin/upsnap serve --http 127.0.0.1:${toString cfg.port}";
              Restart = "on-failure";

              # WOL / raw-socket ping + LAN scan
              AmbientCapabilities = [ "CAP_NET_RAW" ];
              CapabilityBoundingSet = [ "CAP_NET_RAW" ];
              NoNewPrivileges = false;
            };
          };

          my.services.ports.upsnap = cfg.port;
          my.tailscale.serve.upsnap.port = cfg.port;
        };
      };
  };
}
