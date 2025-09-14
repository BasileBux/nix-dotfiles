{ config, lib, pkgs, inputs, settings, secrets, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "mt7921e" "kvm-amd" ];
  boot.initrd.kernelModules = [ "mt7921e" "amdgpu" ];
  hardware.enableRedistributableFirmware = true;

  boot.kernelParams = [] ++ lib.optionals (settings.machine == "asus") [
    "video=DP-1:2560x1440@165"
  ];

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

  programs.adb.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

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
      # qt6.qtshadertools

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
      mpv
      stremio
      neovide
      openvpn
      kitty


      # Dev deps
      gcc
      cmake
      gnumake
      cargo
      rustc
      nodejs
      go
      clang
      python3
      git-lfs
      texlive.combined.scheme-full
      jdk

      # Cli tools
      bat

      # nvim
      neovim
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
    ] ++ lib.optionals (settings.machine == "asus") [ 
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
    ];

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    brotli
    zstd
    glib
    stdenv.cc.cc.lib
  ];


  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [] ++ lib.optionals (settings.machine == "asus") [
      rocmPackages.clr.icd
      clinfo
      amdvlk
    ];
  };
  hardware.amdgpu.initrd.enable = true;


  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.geist-mono
    nerd-fonts.go-mono
    nerd-fonts.gohufont
  ];

  services.supergfxd = {
    enable = settings.machine == "asus";
    settings = {
      mode = "Integrated";
      always_reboot = false;
      no_logind = false;
    };
};

  services.asusd.enable = true;
  services.upower.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.devmon.enable = true;

  services.openvpn.servers.hs_ch = {
    config = "config /home/${settings.username}/.config/openvpn/HotspotShield_CH_v4.ovpn";
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

