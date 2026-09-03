{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  port = 8090;
  mediafetch = inputs.mediafetch.packages.${pkgs.stdenv.hostPlatform.system}.default;

  configFile = pkgs.writeText "mediafetch.yaml" ''
    server:
      addr: "127.0.0.1:${toString port}"

    qbittorrent:
      base_url: "http://127.0.0.1:8081"
      username: "admin"
      # Points at QB_PASS from the shared qbittorrent.env.age (see below), so
      # the WebUI password only ever has to be changed in one place.
      password_env: "QB_PASS"

    yts:
      enabled: true
      base_url: "https://yts.gg"

    paths:
      movie: "/media/jellyfin/movies/{title} ({year})"
      tv: "/media/jellyfin/shows/{title}"

    categories:
      movie: "movies"
      tv: "shows"

    db_path: "/var/lib/mediafetch/mediafetch.db"
  '';
in
{
  users.users.mediafetch = {
    isSystemUser = true;
    group = "mediafetch";
  };
  users.groups.mediafetch = { };

  systemd.services.mediafetch = {
    description = "mediafetch — media downloader (archive.org/YTS → qBittorrent)";
    after = [
      "network-online.target"
      "qbittorrent.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${lib.getExe mediafetch} -config ${configFile}";
      # qbittorrent.env.age is the single source of truth for the qBittorrent
      # WebUI credentials (QB_USER/QB_PASS); mediafetch.env.age only holds the
      # app's own shared household password.
      EnvironmentFile = [
        config.age.secrets."hosts/genome/qbittorrent.env.age".path
        config.age.secrets."hosts/genome/mediafetch.env.age".path
      ];

      User = "mediafetch";
      Group = "mediafetch";
      StateDirectory = "mediafetch";
      Restart = "on-failure";
      RestartSec = 5;

      # Hardening: the app only needs outbound HTTP (archive.org/YTS/qBittorrent)
      # and its SQLite state directory.
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
    };
  };

  my.services.ports.mediafetch = port;
  my.tailscale.serve.mediafetch.port = port;
}
