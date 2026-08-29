{ config, pkgs, lib, ... }:

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
    kernelParams = lib.mkMerge [
      [ "transparent_hugepage=never" ]
      (lib.mkAfter [
        # Cancel the aggressive "pcie_aspm.policy=powersupersave" injected by
        # nixos-hardware's asus-zephyrus-ga402 module (keep it last: the kernel
        # uses the last occurrence of a duplicate cmdline parameter).
        # Deep PCIe ASPM (L1 substates) hard-freezes the display engine during
        # amdgpu BOCO runtime-PM / platform-profile power transitions on this
        # machine (freeze with audio still playing, nothing in the logs).
        "pcie_aspm.policy=default"
      ])
    ];
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
  ];

  programs.nix-ld.enable = true;

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
