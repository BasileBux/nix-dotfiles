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
        2049 # NFS
      ];
      allowedTCPPorts = [ 2049 ]; # NFS
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /home/basileb 100.79.180.68/24(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
