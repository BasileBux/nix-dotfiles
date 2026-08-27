{ config, pkgs, ... }:

let
  gs = config.my.genomeServices;
  scripts = pkgs.callPackage ../../../packages/qbittorrent-scripts { };
in
{
  services.qbittorrent = {
    enable = true;
    user = "qbittorrent";
    group = "qbittorrent";
    webuiPort = gs.ports.qbittorrent;
    torrentingPort = gs.ports.torrentPeers;
    openFirewall = false;

    serverConfig = {
      # Bind qBittorrent to the tailscale IP. libtorrent cannot enumerate
      # addresses on TUN devices (tailscale0), so "all interfaces" silently
      # never binds the 100.x address. With the Mullvad exit node active,
      # traffic bound to the LAN IP (192.168.1.x) is dropped, which killed
      # DHT/trackers. Binding to the tailscale IP makes all traffic go
      # through the exit node. NOTE: torrenting only works while an exit
      # node is active.
      BitTorrent = {
        Session = {
          Interface = "100.82.254.103";
        };
      };
      Preferences = {
        WebUI = {
          Username = "admin";
          Password_PBKDF2 = "@ByteArray(96J+Eeh3xG+Et8h1teXl9A==:hzJZqeB/3zBFTBhJZQYZNVOwO1ghex4aMfxV2O89S9HsDBecpg6n0ctFlvQn2RxmfVfPvmFIIyFrm+os7J4P0w==)";
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

  networking.firewall.allowedTCPPorts = [ gs.ports.torrentPeers ];
  networking.firewall.allowedUDPPorts = [ gs.ports.torrentPeers ];

  users.users.qbittorrent.extraGroups = [ "media" ];

  systemd.services.qbittorrent = {
    path = [ pkgs.openssh pkgs.rsync pkgs.curl pkgs.bash ];
    serviceConfig.EnvironmentFile = [ gs.secrets.qbittorrentEnv ];
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
      EnvironmentFile = [ gs.secrets.qbittorrentEnv ];
      ExecStart = "${pkgs.bash}/bin/bash ${scripts}/bin/qbittorrent-init.sh";
    };
    path = with pkgs; [ curl bash coreutils ];
  };
}
