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

  # Default categories; the file format matches qBittorrent 5.x's own
  # categories.json. qBittorrent may add more categories at runtime; the ones
  # declared here are re-pinned on every start by the reconcile script below.
  # Arr-managed downloads (Sonarr/Radarr) must go to /media/downloads/* so the
  # arrs can import/rename/move them into the library; downloading straight
  # into the root folders breaks that (files are already "in place").
  # The jellyfin-* categories are for manual grabs that intentionally skip the
  # arrs and land directly in the library. The fam-* categories belong to the
  # family stack's arrs on the Synology NAS (never reuse tv/movies for them:
  # two arrs on one category causes grab/import conflicts).
  categoriesFile = pkgs.writeText "categories.json" (
    builtins.toJSON {
      tv.save_path = "/media/downloads/tv";
      movies.save_path = "/media/downloads/movies";
      "fam-tv".save_path = "/media/downloads/fam/tv";
      "fam-movies".save_path = "/media/downloads/fam/movies";
      jellyfin-shows.save_path = "/media/jellyfin/shows";
      jellyfin-movies.save_path = "/media/jellyfin/movies";
    }
  );

  # qBittorrent auto-creates categories (with an EMPTY save path) the moment
  # an arr connects using an unknown category name. If that happens before
  # this file was ever seeded (e.g. the arrs were wired up before a genome
  # deploy), the old install-if-absent seed never repaired it and torrents
  # landed in <DefaultSavePath>/<category> (/media/downloads/fam-movies).
  # So instead of seeding once, reconcile on every start: create missing
  # declared categories and re-pin their save_path, while leaving everything
  # else in the file (WebUI-set share limits, extra categories) untouched.
  reconcileCategories = pkgs.writeShellScript "qbittorrent-reconcile-categories" ''
    f=/var/lib/qBittorrent/qBittorrent/config/categories.json
    if [ ! -e "$f" ]; then
      ${pkgs.coreutils}/bin/install -m600 ${categoriesFile} "$f"
      exit 0
    fi
    tmp=$(${pkgs.coreutils}/bin/mktemp)
    if ${pkgs.jq}/bin/jq --slurpfile s ${categoriesFile} \
        'reduce ($s[0] | to_entries[]) as $e (.; .[$e.key].save_path = $e.value.save_path)' \
        "$f" > "$tmp"; then
      ${pkgs.coreutils}/bin/install -m600 "$tmp" "$f"
    else
      # Unparseable file: qBittorrent couldn't use it anyway, re-seed.
      ${pkgs.coreutils}/bin/install -m600 ${categoriesFile} "$f"
    fi
    ${pkgs.coreutils}/bin/rm -f "$tmp"
  '';

  # tmpfiles 'd' rules only apply ownership/mode at creation, so if someone
  # recreates these dirs by hand (e.g. while cleaning up a misplaced torrent)
  # they come back group-read-only and qBittorrent hits "file_open: Permission
  # denied" on every download. Re-assert owner/mode as root on every start.
  fixDownloadDirs = pkgs.writeShellScript "qbittorrent-fix-download-dirs" ''
    for d in /media/downloads/fam /media/downloads/fam/tv /media/downloads/fam/movies; do
      ${pkgs.coreutils}/bin/install -d -o qbittorrent -g media -m 2775 "$d"
    done
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

  # Pre-create the fam-* save paths (setgid + group media, matching what
  # qBittorrent would create); also makes them visible in the NFS export to
  # the NAS before the first family torrent lands.
  systemd.tmpfiles.rules = [
    "d /media/downloads/fam 2775 qbittorrent media - -"
    "d /media/downloads/fam/tv 2775 qbittorrent media - -"
    "d /media/downloads/fam/movies 2775 qbittorrent media - -"
  ];

  systemd.services.qbittorrent = {
    # Files land group-writable (rw-rw-r--) so other media-group members can
    # manage them; the setgid bit on the download dirs supplies the group.
    serviceConfig.UMask = "0002";

    # Runs after the module's own ExecStartPre (which installs the
    # store-rendered qBittorrent.conf on every start).
    serviceConfig.ExecStartPre = lib.mkAfter [
      "${reconcileCategories}"
      "+${fixDownloadDirs}"
    ];
  };
}
