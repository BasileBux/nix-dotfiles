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
