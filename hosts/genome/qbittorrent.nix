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
  scripts = pkgs.callPackage ../../packages/qbittorrent-scripts { };
  webuiPort = 8081;
  torrentingPort = 51413;
in
{
  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
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
        };
      };
      Preferences = {
        WebUI = {
          # Credentials are deliberately NOT set here: a PBKDF2 hash baked into
          # qBittorrent.conf via pkgs.writeText lands in the world-readable nix
          # store, gets committed to the repo, and drifts from the agenix env.
          # Instead, the ExecStartPre below patches WebUI\\Username and
          # WebUI\\Password_PBKDF2 from QB_USER/QB_PASS (hosts/genome/
          # qbittorrent.env.age) into the installed config on every start.
          HostHeaderValidation = false;
        };
        General.Locale = "en";
        Downloads = {
          AutorunEnabled = true;
          AutorunProgram = "/run/current-system/sw/bin/torrent-done.sh %I %D %N %L %F";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ torrentingPort ];
  networking.firewall.allowedUDPPorts = [ torrentingPort ];

  my.services.ports.qbittorrent = webuiPort;
  my.services.ports.qbittorrent-peers = torrentingPort;
  my.tailscale.serve.qbittorrent.port = webuiPort;

  users.users.qbittorrent.extraGroups = [ "media" ];

  systemd.services.qbittorrent = {
    path = [
      pkgs.openssh
      pkgs.rsync
      pkgs.curl
      pkgs.bash
    ];
    serviceConfig.EnvironmentFile = [ config.age.secrets."hosts/genome/qbittorrent.env.age".path ];

    # Runs after the module's own ExecStartPre (which installs the
    # store-rendered qBittorrent.conf on every start), making the age env the
    # single source of truth for the WebUI credentials — including across
    # plain service restarts, not just full boots.
    serviceConfig.ExecStartPre = lib.mkAfter [
      "${pkgs.python3}/bin/python3 ${scripts}/bin/qbittorrent-creds.py"
    ];
  };

  environment.systemPackages = [ scripts ];

  systemd.services.qbittorrent-init = {
    description = "Configure qBittorrent WebUI/categories/torrent-done hook";
    after = [ "qbittorrent.service" ];
    wants = [ "qbittorrent.service" ];
    before = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "qbittorrent";
      Group = "qbittorrent";
      EnvironmentFile = [ config.age.secrets."hosts/genome/qbittorrent.env.age".path ];
      ExecStart = "${pkgs.bash}/bin/bash ${scripts}/bin/qbittorrent-init.sh";
    };
    path = with pkgs; [
      curl
      bash
      coreutils
    ];
  };
}
