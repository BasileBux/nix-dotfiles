{
  flake.module.system-defaults.nixos = {
    hardware.enableRedistributableFirmware = true;
    networking.networkmanager = {
      enable = true;
      wifi.macAddress = "random";
    };
    time.timeZone = "Europe/Amsterdam";
    console = {
      font = "Lat2-Terminus16";
      earlySetup = true;
      useXkbConfig = true;
    };
    services.xserver.xkb = {
      layout = "us,ch";
      variant = ",fr";
      options = "grp:alt_space_toggle,ctrl:nocaps";
    };
  };
}
