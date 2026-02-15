{ config, lib, pkgs, pkgs-unstable, inputs, settings, secrets, ... }:

{
  imports = [ ./hardware-configuration.nix ]
    ++ lib.optionals (settings.machine == "asus") [ ./hosts/asus-g14.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "mt7921e" ];
  boot.initrd.kernelModules = [ "mt7921e" ];
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "${settings.username}-${settings.machine}";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  console = {
    font = "Lat2-Terminus16";
    earlySetup = true;
    useXkbConfig = true;
  };
  services.xserver.xkb = {
    layout = "us,ch";
    variant = ",fr";
    options = "grp:alt_space_toggle,ctrl:nocaps";
  };

  services.flatpak.enable = true;

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

  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "kvm" "adbusers" "wireshark" ];
    packages = with pkgs; [ tree ];
    shell = pkgs.zsh;
  };

  home-manager = { users = { "${settings.username}" = import ./home.nix; }; };

  programs.zsh.enable = true;

  # Cachix for Hyprland binaries
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys =
      [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland.enable = true;
  programs.hyprland.package =
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    SUDO_EDITOR = "/run/current-system/sw/bin/nvim";
    EDITOR = "/run/current-system/sw/bin/nvim";
    NIXOS_OZONE_WL = "1";
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    dumpcap.enable = true;
  };

  # Docker
  virtualisation.docker = { enable = true; };

  virtualisation.vmware.host.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

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
      zip
      jq
      gparted
      bluez
      bc
      bat
      btop
      file
      patchelf
      man-pages
      man-pages-posix
      inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      appimage-run

      # Codecs
      libva
      libGL
      ffmpeg-full
      openh264

      # Software
      nautilus
      blueman
      pavucontrol
      yazi
      eog
      evince
      gnome-disk-utility
      firefox
      (pkgs.callPackage ./custom-packages/helium-browser.nix { })
      obs-studio
      # kdePackages.kdenlive
      localsend
      vesktop
      mpv
      vlc
      qbittorrent
      neovide
      openvpn
      ghidra-bin
      zed-editor
      libreoffice
      typst
      steam
      sage
      gnome-calculator
      pinta
      winboat
      wireshark
      thunderbird
      zenity
      jellyfin-desktop

      # Dev deps
      gcc
      gcc_multi
      cmake
      gnumake
      rustc
      rustfmt
      rust-analyzer
      clippy
      nodejs
      go
      clang
      python3
      git-lfs
      texlive.combined.scheme-full
      jdk
      gdb
      bun
      openssl

      radicle-node
      radicle-desktop

      # nvim
      ripgrep
      fd
      fzf
      gcc
      cargo
      rustc
      luarocks
      stylua
      clang-tools
      tree-sitter
      imagemagick
      ghostscript
    ] ++ [ pkgs-unstable.neovim ];

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [ brotli zstd glib stdenv.cc.cc.lib ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
    inter
    dm-sans
  ];

  services.upower.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  services.tailscale.enable = true;

  age.identityPaths = [
    "/home/${settings.username}/.ssh/id_ed25519"
    "/home/${settings.username}/.ssh/basileb"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "${settings.nixosVersion}"; # Did you read the comment?
}

