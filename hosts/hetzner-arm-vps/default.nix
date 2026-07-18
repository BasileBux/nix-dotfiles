{ pkgs, ... }:

{
  imports = [
    ./disko-config.nix
  ];

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev"; # required when efiSupport = true
    };
    efi.canTouchEfiVariables = false;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

}
