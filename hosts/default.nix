{
  pkgs,
  settings,
  lib,
  ...
}:

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
    unzip
    zip
    jq
    bc
    btop
    file
    difftastic
  ];

  programs.mosh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PubkeyAuthentication = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      port = 2222;
    };
  };
  programs.ssh.startAgent = true;
  security.pam.services.sshd.unixAuth = lib.mkForce true;

  services.tailscale.enable = true;

  system.stateVersion = settings.nixosVersion; # DO NOT CHANGE THIS EVER
}
