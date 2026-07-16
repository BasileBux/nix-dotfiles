{
  pkgs,
  settings,
  ...
}:

{
  imports = [
    ../profiles/smb.nix
  ];

  boot = {
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [
      "mt7921e"
      "spi_bcm2835"
      "spidev"
    ];
    initrd.kernelModules = [ "mt7921e" ];

    # For VMWare stability
    kernelParams = [
      "transparent_hugepage=never"
    ];
    kernel.sysctl = {
      "vm.compaction_proactiveness" = 0;
    };
  };

  users.users.${settings.username} = {
    extraGroups = [
      # "wireshark" # Enable only when needed
    ];
  };

  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    dumpcap.enable = true;
  };

  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
    powertop
    pciutils
    ryzenadj
    nvtopPackages.amd

    platformio-core
  ];

  programs.nix-ld.enable = true;

  environment.sessionVariables = {
    PI_SKIP_VERSION_CHECK = "1";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      clinfo
    ];
  };

  services.supergfxd = {
    enable = true;
    settings = {
      always_reboot = false;
      vfio_enable = false;
      no_logind = false;
      hotplug_type = "Asus";
    };
  };
  services.asusd.enable = true;
}
