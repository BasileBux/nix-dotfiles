{
  pkgs,
  ...
}:

let
  customFonts = pkgs.callPackage ../../dotfiles/fonts { };
in
{
  imports = [
    ./disko-config.nix
    ./remote-nvim.nix
  ];

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    customFonts.iosevka-custom
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

  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];

  networking.interfaces.enp1s0.ipv6.addresses = [
    {
      address = "2a01:4f8:c014:ef6::1";
      prefixLength = 64;
    }
  ];

  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "enp1s0";
  };

  networking.nameservers = [
    "2a01:4ff:ff00::add:1"
    "2a01:4ff:ff00::add:2"
    "185.12.64.2"
    "185.12.64.1"
  ];

  networking.interfaces.enp1s0.useDHCP = true;
}
