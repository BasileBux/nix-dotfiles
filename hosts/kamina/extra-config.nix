{
  pkgs,
  ...
}:
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
      allowPing = true;
    };
  };

  # Used for upsnap WOL + remote shutdown
  security.sudo.extraRules = [
    {
      users = [ "basileb" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [
    pkgs.codex
  ];
}
