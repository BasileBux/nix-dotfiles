{ config, lib, pkgs, pkgs-unstable, inputs, settings, secrets, ... }:

{
  boot.kernelParams = [ "video=DP-1:2560x1440@165" "amdgpu.runpm=0" ];
  boot.supportedFilesystems = [ "ntfs" ];

  environment.systemPackages = with pkgs; [
    asusctl
    supergfxctl
    radeontop
    powertop
    pciutils
    ryzenadj
    nvtopPackages.amd
    (writeShellScriptBin "asusrog-dgpu-disable" ''
      echo 1 | sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo 1 | sudo tee /sys/bus/pci/rescan
      echo 1 | sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo "please logout and login again to use integrated graphics"
    '')
    (writeShellScriptBin "asusrog-dgpu-enable" ''
      echo 0 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo 1 |sudo tee /sys/bus/pci/rescan
      echo 0 |sudo tee /sys/devices/platform/asus-nb-wmi/dgpu_disable
      echo "please reboot to use discrete graphics"
    '')
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd clinfo amdvlk ];
  };

  services.supergfxd = {
    enable = true;
    settings = {
      mode = "Integrated";
      always_reboot = false;
      no_logind = false;
      hotplug_type = "Asus";
    };
  };
  services.asusd.enable = true;
}
