{ pkgs, ... }:

{
  imports = [
    ./disko-config.nix
    ./limits-nvim.nix
  ];

  users.users.nvim = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  services.openssh.extraConfig = ''
    Match User nvim
      PasswordAuthentication yes
      KbdInteractiveAuthentication yes
      PubkeyAuthentication no
  '';

  home-manager.users.nvim = import ./home-nvim.nix;

  system.activationScripts.copyNvimPlugins = ''
    SRC=/home/eugene/.local/share/nvim/site
    DST=/home/nvim/.local/share/nvim/site
    if [ -d "$SRC" ]; then
      mkdir -p "$DST"
      cp -ru "$SRC"/. "$DST"/
      chown -R nvim:users "$DST"
    fi
  '';

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
