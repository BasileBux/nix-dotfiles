# Host-local on purpose: the export encodes the tailnet-only topology of the
# family media stack (NAS is buxtorf-synology, not managed by the flake).
#
# Read-only NFS export of the download dir so the family arrs on the Synology
# can import (copy) completed torrents. With the Mullvad exit node active,
# genome's LAN-IP traffic is dropped, so genome <-> NAS traffic must use
# tailnet addresses; binding nfsd to the tailscale IP keeps the export
# tailnet-only (defense in depth on top of the client restriction below).
#
# NFSv3, not v4: DSM's kernel NFS client cannot complete an NFSv4 mount
# (its mount.nfs predates minor versions and fails with EPROTONOSUPPORT),
# so v3 is the newest protocol the NAS can actually speak.
{
  config,
  ...
}:

let
  nasTailnetIp = "100.86.179.75";
in
{
  services.nfs = {
    settings = {
      nfsd = {
        vers2 = false;
        vers3 = true;
      };
      # Pin mountd's port so the tailnet exposure is a fixed, known set.
      mountd.port = 20048;
    };

    server = {
      enable = true;
      hostName = config.my.tailscale.self.ip;

      # Read-only: the NAS only ever reads. Default root_squash maps the NAS
      # root to nobody, which can still read everything because qBittorrent's
      # UMask 0002 leaves files 664 and dirs 2775 (world-readable).
      exports = {
        "/media/downloads" = {
          "${nasTailnetIp}" = [
            "ro"
            "async"
            "no_subtree_check"
          ];
        };
      };
    };
  };

  # v3 needs rpcbind (111) and mountd (20048) in addition to 2049. Those are
  # already reachable from the tailnet (the tailscale interface chain accepts
  # all traffic) and stay blocked from the LAN by nixos-fw; the export above
  # remains restricted to the NAS's IP.
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    2049
    111
    20048
  ];
}
