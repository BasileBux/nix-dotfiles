{ config, lib, pkgs, pkgs-unstable, inputs, settings, secrets, ... }:

{
  # amdgpu.dcdebugmask=0x4, pcie_aspm=force, amdgpu.sg_display=0 -> might help with stability issues
  boot.kernelParams = [ "amdgpu.runpm=0" ];
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
    (writeShellScriptBin "toggle-external-monitor" ''
      INTERNAL_DESC="Thermotrex Corporation TL140ADXP01"
      EXT="DP-1"
      if hyprctl monitors all -j | jq -e '.[] | select(.name == "'"$EXT"'")' >/dev/null; then
          hyprctl keyword monitor "desc:$INTERNAL_DESC",disable
          pkill quickshell
          quickshell -d
      else
          hyprctl keyword monitor "desc:$INTERNAL_DESC",2560x1600@60Hz,0x0,1.6
          pkill quickshell
          quickshell -d
      fi
    '')
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd clinfo ];
  };

  services.supergfxd = {
    enable = true;
    settings = {
      always_reboot = false;
      no_logind = false;
      hotplug_type = "Asus";
    };
  };
  services.asusd.enable = true;
}
