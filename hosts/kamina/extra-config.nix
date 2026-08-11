{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    interfaces.enp3s0.wakeOnLan.enable = true;
    firewall = {
      allowedUDPPorts = [
        9 # WOL
        2049 # NFS nfsd
        111 # NFS rpcbind
        4001 # NFS mountd
        4002 # NFS statd
        4003 # NFS lockd
      ];
      allowedTCPPorts = [
        2049 # NFS nfsd
        111 # NFS rpcbind
        4001 # NFS mountd
        4002 # NFS statd
        4003 # NFS lockd
      ];
    };
  };

  services.rpcbind.enable = true; # Explicit; auto-enabled by nfs.server but good form

  services.nfs.server = {
    enable = true;
    # Pin ports so NFSv3 fallback works through firewalls
    mountdPort = 4001;
    statdPort = 4002;
    lockdPort = 4003;
    exports = ''
      /               *(fsid=0,ro,no_subtree_check,crossmnt,no_root_squash)
      /home/basileb   100.79.180.68(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
