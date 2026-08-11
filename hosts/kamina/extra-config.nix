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
      allowedUDPPorts = [ 9 ];
    };
  };
}
