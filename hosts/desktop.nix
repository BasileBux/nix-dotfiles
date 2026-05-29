{
  pkgs,
  inputs,
  settings,
  ...
}:

{
  imports = [
    ../smb.nix
  ];

  boot = {
    plymouth.enable = true;

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "udev.log_priority=3"
      "transparent_hugepage=never" # For VMWare stability
    ];

    # For VMWare stability
    kernel.sysctl = {
      "vm.compaction_proactiveness" = 0;
    };
  };

  users.users.${settings.username} = {
    extraGroups = [
      "kvm"
      "wireshark"
      "dialout"
    ];
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  virtualisation.vmware.host.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    # Utils
    wl-clipboard
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
    mpv
    zenity
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

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
    imhex
    vlc
    opencode
    gh
    pi-coding-agent

    radicle-node
    radicle-desktop
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

  # Enable nautilus to automount
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
