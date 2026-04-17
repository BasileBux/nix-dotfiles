{
  lib,
  pkgs,
  inputs,
  settings,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ lib.optionals (settings.machine == "asus") [ ./hosts/asus-g14.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    extraGroups = [
      "wheel"
      "docker"
      "kvm"
      "wireshark"
      "dialout"
    ];
    packages = with pkgs; [ tree ];
    shell = pkgs.zsh;
  };

  home-manager = {
    users = {
      "${settings.username}" = import ./home.nix;
    };
  };

  programs.zsh.enable = true;

  # Cachix for Hyprland binaries
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

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

  virtualisation.docker = {
    enable = true;
  };

  virtualisation.vmware.host.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

  environment.systemPackages = with pkgs; [
    # Utils
    wget
    curl
    git
    wl-clipboard
    openssh
    unzip
    zip
    jq
    bc
    bat
    btop
    file
    patchelf
    man-pages
    man-pages-posix
    appimage-run

    # Codecs
    libva
    libGL
    ffmpeg-full
    openh264

    # Software
    nautilus
    kdePackages.gwenview
    evince
    (pkgs.callPackage ./custom-packages/helium-browser.nix { })
    mpv
    zenity

    # Optional Software
    blueman
    pavucontrol
    yazi
    vesktop
    neovide
    ghidra-bin
    steam
    gnome-calculator
    pinta
    wireshark
    thunderbird
    jellyfin-desktop
    wireguard-tools
    imhex
    vlc
    opencode

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
    texlive.combined.scheme-full
    gdb
    bun
    openssl
    difftastic
    typst
    sage

    radicle-node
    radicle-desktop

    # nvim
    neovim-unwrapped
    ripgrep
    fd
    fzf
    gcc
    cargo
    rustc
    luarocks
    tree-sitter
    imagemagick
    ghostscript

    # lsp and formatters
    basedpyright
    cmake-language-server
    stylua
    clang-tools
    gopls
    gotools
    ltex-ls
    lua-language-server
    nil
    nixfmt
    prettier
    kdePackages.qtdeclarative # qmlls
    tinymist
    typescript-language-server
    typstyle
  ];

  # Skip sage tests as they take ages to execute and are not relevant for my use.
  # However, in a production environment, these tests must be executed.
  nixpkgs.overlays = [
    (final: prev: {
      sage = prev.sage.override { requireSageTests = false; };
    })
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
    inter
    dm-sans
    googlesans-code
  ];

  services.upower.enable = true;

  services.tailscale.enable = true;

  # Enable nautilus to automount
  services.gvfs.enable = true;
  services.udisks2.enable = true;

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
