{ pkgs, settings, ... }:

{
  networking.hostName = settings.hostname;
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

  security.rtkit.enable = true;
  security.sudo.extraConfig = "Defaults pwfeedback";

  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    users = {
      "${settings.username}" = import ../home.nix;
    };
  };

  programs.zsh.enable = true;

  environment.sessionVariables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
    btop
    file
    difftastic
  ];

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  programs.ssh.startAgent = true;

  services.tailscale.enable = true;

  system.stateVersion = settings.nixosVersion; # DO NOT CHANGE THIS EVER
}
