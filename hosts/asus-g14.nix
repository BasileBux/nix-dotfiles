{
  pkgs,
  ...
}:

{
  # amdgpu.dcdebugmask=0x4, pcie_aspm=force, amdgpu.sg_display=0 -> might help with stability issues
  # boot.kernelParams = [ "amdgpu.runpm=0" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelModules = [ "mt7921e" ];
  boot.initrd.kernelModules = [ "mt7921e" ];

  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
    powertop
    pciutils
    ryzenadj
    nvtopPackages.amd
  ];

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

  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    environmentVariables = {
      HCC_AMDGPU_TARGET = "gfx1032";
    };
    rocmOverrideGfx = "10.3.0";
  };
}
