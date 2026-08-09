{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
    kernelModules = [
      "mt7921e"
      "spi_bcm2835"
      "spidev"
    ];
    initrd.kernelModules = [ "mt7921e" ];
    kernelParams = [ "transparent_hugepage=never" ];
    kernel.sysctl."vm.compaction_proactiveness" = 0;
  };

  users.users.${config.my.settings.username}.extraGroups = [ ];

  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    dumpcap.enable = true;
  };

  environment.systemPackages = with pkgs; [
    asusctl
    # Wrapper because asusctl getter command sucks ass
    (pkgs.writeShellScriptBin "asusctl-profile-get" ''
      asusctl profile get | grep 'Active profile:' | cut -d' ' -f3
    '')

    supergfxctl
    powertop
    pciutils
    ryzenadj
    nvtopPackages.amd

    nushell
  ];

  programs.nix-ld.enable = true;

  environment.sessionVariables.PI_SKIP_VERSION_CHECK = "1";

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
