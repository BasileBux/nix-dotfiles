{
  pkgs,
  config,
  inputs,
  ...
}:
let
  todoPort = 8787;
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
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "exec";
      User = config.my.settings.username;
      ExecStart = "${todo}/bin/todo -host 127.0.0.1 -port ${toString todoPort} -file /home/${config.my.settings.username}/todo.md";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

  my.services.ports.simple-todo = todoPort;
  my.tailscale.serve.simple-todo.port = todoPort;
}
