{
  pkgs,
  settings,
  pkgs_stable,
  ...
}:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

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
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    users = {
      "${settings.username}" = import ./home.nix;
    };
  };

  programs.zsh.enable = true;

  environment.sessionVariables = {
    SUDO_EDITOR = "/run/current-system/sw/bin/nvim";
    EDITOR = "/run/current-system/sw/bin/nvim";
  };

  virtualisation.docker = {
    enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Utils
    wget
    curl
    git
    openssh
    mosh
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
    perf
    tree

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
    lua
    clang
    python3
    texlive.combined.scheme-full
    gdb
    bun
    openssl
    difftastic
    typst
    pkgs_stable.sage

    radicle-node
  ];

  services.tailscale.enable = true;

  services.openssh.enable = true;
  programs.ssh.startAgent = true;
}
