{ config, lib, pkgs, pkgs-unstable, inputs, settings, secrets, ... }:

{
  imports = [ ./hardware-configuration.nix ]
    ++ lib.optionals (settings.machine == "asus") [ ./hosts/asus-g14.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelModules = [ "mt7921e" ];
  boot.initrd.kernelModules = [ "mt7921e" ];
  hardware.enableRedistributableFirmware = true;

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

  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "kvm" "adbusers" ];
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

  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.vmware.host.enable = true;

  programs.adb.enable = true;

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
      jq
      gparted
      bluez
      bc
      bat
      btop

      # Codecs
      libva
      libGL
      ffmpeg-full
      mediastreamer
      openh264
      mediastreamer-openh264

      # Software
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
      mpv
      vlc
      qbittorrent
      # stremio # Uses qtwebengine-5.15.19 which is insecure
      neovide
      openvpn
      kitty

      # Dev deps
      gcc
      cmake
      gnumake
      cargo
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
    ] ++ (with pkgs-unstable; [ neovim ]);

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [ brotli zstd glib stdenv.cc.cc.lib ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
  ];

  services.upower.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  services.openvpn.servers.hs_ch = {
    config =
      "config /home/${settings.username}/.config/openvpn/HotspotShield_CH_v4.ovpn";
    autoStart = false;
    authUserPass = {
      username = secrets.hotspotshield.username or "";
      password = secrets.hotspotshield.password or "";
    };
    updateResolvConf = true;
  };

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

  system.stateVersion = "${settings.nixosVersion}"; # Did you read the comment?
}

