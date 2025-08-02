{ config, lib, pkgs, inputs, settings, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "${settings.username}-${settings.machine}";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  console = {
    keyMap = "us";
    # keyMap = "fr_CH-latin1";
    font = "Lat2-Terminus16";
  };

  services.printing.enable = false;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.zsh;
  };

  home-manager = { users = { "${settings.username}" = import ./home.nix; }; };

  programs.zsh.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SUDO_EDITOR = "/run/current-system/sw/bin/nvim";
    EDITOR = "/run/current-system/sw/bin/nvim";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs;
    [
      # Utils
      wget
      curl
      git
      pamixer
      wl-clipboard
      openssh
      upower
      unzip
      jq
      gparted
      bluez

      # Codecs
      libva
      libGL
      ffmpeg-full
      mediastreamer
      openh264
      mediastreamer-openh264

      # Software
      btop
      nautilus
      blueman
      pavucontrol
      yazi
      eog
      evince
      gnome-disk-utility
      firefox
      obs-studio
      kdePackages.kdenlive
      localsend
      vesktop

      # Dev deps
      gcc
      cmake
      gnumake
      cargo
      rustc
      nodejs
      go
    ] ++ lib.optionals (settings.machine == "asus") [ asusctl supergfxctl ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
  ];

  services.asusd.enable = true;
  services.upower.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "${settings.nixosVersion}"; # Did you read the comment?

}

