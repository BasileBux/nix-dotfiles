{
  pkgs,
  settings,
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
  security.sudo.extraConfig = "Defaults pwfeedback";

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
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    users = {
      "${settings.username}" = import ../home.nix;
    };
  };

  programs.zsh.enable = true;

  environment.sessionVariables = {
    SUDO_EDITOR = "/run/current-system/sw/bin/nvim";
    EDITOR = "/run/current-system/sw/bin/nvim";
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
    jujutsu
    openssh
    mosh
    unzip
    zip
    jq
    bc
    bat
    btop
    file
    man-pages
    man-pages-posix
    perf
    tree
    difftastic

    # C / C++
    gcc
    gcc_multi
    cmake
    gnumake
    clang
    gdb

    # Rust
    rustc
    rustfmt
    rust-analyzer
    clippy

    # js
    nodejs
    bun

    # Misc dev deps
    go
    lua
    python313
    python313Packages.pip
  ];

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  system.stateVersion = settings.nixosVersion; # DO NOT CHANGE THIS EVER
}
