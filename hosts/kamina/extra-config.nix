{
  pkgs,
  config,
  inputs,
  ...
}:
let
  # kamina's Tailscale address (same IP the t3 service binds to)
  tailscaleHost = "100.100.86.25";
  todo = inputs.simple-todo.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    interfaces.enp3s0.wakeOnLan.enable = true;
    firewall = {
      allowedUDPPorts = [ 9 ];
      allowPing = true;
    };
  };

  # Used for upsnap WOL + remote shutdown
  security.sudo.extraRules = [
    {
      users = [ "basileb" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/poweroff";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = [
    todo
    pkgs.codex
  ];

  systemd.services.simple-todo = {
    description = "Simple todo web server (markdown file editor/viewer)";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    serviceConfig = {
      Type = "exec";
      User = config.my.settings.username;
      ExecStart = "${todo}/bin/todo -host ${tailscaleHost} -port 8787 -file /home/${config.my.settings.username}/todo.md";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
