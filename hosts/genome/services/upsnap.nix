{ config, pkgs, ... }:

let
  gs = config.my.genomeServices;
  upsnap = pkgs.callPackage ../../../packages/upsnap { };
in
{
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
      TZ = "Europe/Zurich";
      UPSNAP_HTTP_LISTEN = "127.0.0.1:${toString gs.ports.upsnap}";
      HOME = "/var/lib/upsnap";
    };

    path = [ pkgs.openssh pkgs.nmap pkgs.curl pkgs.bash ];

    serviceConfig = {
      Type = "simple";
      User = "upsnap";
      Group = "upsnap";
      StateDirectory = "upsnap";
      WorkingDirectory = "/var/lib/upsnap";
      ExecStart = "${upsnap}/bin/upsnap serve --http 127.0.0.1:${toString gs.ports.upsnap}";
      Restart = "on-failure";

      # WOL / raw-socket ping + LAN scan
      AmbientCapabilities = [ "CAP_NET_RAW" ];
      CapabilityBoundingSet = [ "CAP_NET_RAW" ];
      NoNewPrivileges = false;
    };
  };
}
