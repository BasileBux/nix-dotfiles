# Host-local on purpose: the Interface binding below encodes genome-specific
# exit-node networking. Still participates in the shared framework via
# my.services.ports / my.tailscale.serve.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  webuiPort = 8081;
  torrentingPort = 51413;

  # Default categories, seeded once into the profile on first start
  # (categories are stored in categories.json, not in qBittorrent.conf).
  # qBittorrent owns the file afterwards, so category edits made through the
  # WebUI persist across restarts; only a wiped profile gets re-seeded.
  # Arr-managed downloads (Sonarr/Radarr) must go to /media/downloads/* so the
  # arrs can import/rename/move them into the library; downloading straight
  # into the root folders breaks that (files are already "in place").
  # The jellyfin-* categories are for manual grabs that intentionally skip the
  # arrs and land directly in the library.
  categoriesFile = pkgs.writeText "categories.json" (
    builtins.toJSON {
      tv.save_path = "/media/downloads/tv";
      movies.save_path = "/media/downloads/movies";
      jellyfin-shows.save_path = "/media/jellyfin/shows";
      jellyfin-movies.save_path = "/media/jellyfin/movies";
    }
  );

  # Runs after the module's own ExecStartPre (which installs the
  # store-rendered qBittorrent.conf on every start).
  seedCategories = pkgs.writeShellScript "qbittorrent-seed-categories" ''
    if [ ! -e /var/lib/qBittorrent/qBittorrent/config/categories.json ]; then
      ${pkgs.coreutils}/bin/install -m600 ${categoriesFile} \
        /var/lib/qBittorrent/qBittorrent/config/categories.json
    fi
  '';
in
{
  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    # The systemd unit launches with this group; users.users.<name>.extraGroups
    # only edits the group database and is ignored by the unit. Needed to write
    # into /media/downloads and read the library.
    group = "media";
    webuiPort = webuiPort;
    torrentingPort = torrentingPort;
    openFirewall = false;

    serverConfig = {
      # libtorrent cannot enumerate addresses on TUN devices (tailscale0), so
      # "all interfaces" never binds the 100.x address; with the Mullvad exit
      # node active, traffic on the LAN IP is dropped, killing DHT/trackers.
      # NOTE: torrenting only works while an exit node is active.
      BitTorrent = {
        Session = {
          Interface = config.my.tailscale.self.ip;
          Port = torrentingPort;
          UPnP = false;
          DefaultSavePath = "/media/downloads/";

          # Default Torrent Management Mode = Automatic
          DisableAutoTMMByDefault = false;

          # Genome is a Pi 5: keep seeding load bounded. Uncapped upload slots
          # and default connection limits (500/100) caused heavy CPU + power
          # spikes through the exit node and crashed the host twice (2026-09-04).
          GlobalMaxRatio = 1;
          MaxActiveUploads = 2;
          GlobalUPSpeedLimit = 8000; # KiB/s
          MaxConnections = 150;
          MaxUploads = 6;
          MaxConnectionsPerTorrent = 40;
          MaxUploadsPerTorrent = 3;
        };
      };
      Preferences = {
        WebUI = {
          # No password: the WebUI is only reachable from localhost, the LAN
          # and the tailnet (via my.tailscale.serve), all of which bypass auth.
          HostHeaderValidation = false;
          LocalHostAuth = false;
          AuthSubnetWhitelistEnabled = true;
          AuthSubnetWhitelist = "192.168.1.0/24,100.64.0.0/10";
        };
        General.Locale = "en";
        Downloads.UseCategoryPathsInManualMode = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ torrentingPort ];
  networking.firewall.allowedUDPPorts = [ torrentingPort ];

  my.services.ports.qbittorrent = webuiPort;
  my.services.ports.qbittorrent-peers = torrentingPort;
  my.tailscale.serve.qbittorrent.port = webuiPort;

  systemd.services.qbittorrent = {
    # Files land group-writable (rw-rw-r--) so other media-group members can
    # manage them; the setgid bit on the download dirs supplies the group.
    serviceConfig.UMask = "0002";

    # Runs after the module's own ExecStartPre (which installs the
    # store-rendered qBittorrent.conf on every start).
    serviceConfig.ExecStartPre = lib.mkAfter [ "${seedCategories}" ];
  };
}
