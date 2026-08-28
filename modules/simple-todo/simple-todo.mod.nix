{
  ...
}:
{
  flake.module.simple-todo = {
    nixos =
      {
        inputs,
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.my.services.simple-todo;
        todo = inputs.simple-todo.packages.${pkgs.stdenv.hostPlatform.system}.default;
      in
      {
        options.my.services.simple-todo = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable Simple todo web server (served on the tailnet)";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 8787;
            description = "Loopback port for the web UI";
          };

          file = lib.mkOption {
            type = lib.types.path;
            default = "/home/${config.my.settings.username}/todo.md";
            description = "Markdown file edited/viewed by the service";
          };
        };

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [ todo ];

          # Runs as the primary user: the todo file lives in their home.
          systemd.services.simple-todo = {
            description = "Simple todo web server (markdown file editor/viewer)";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
              Type = "exec";
              User = config.my.settings.username;
              ExecStart = "${todo}/bin/todo -host 127.0.0.1 -port ${toString cfg.port} -file ${cfg.file}";
              Restart = "on-failure";
              RestartSec = 10;
            };
          };

          my.services.ports.simple-todo = cfg.port;
          my.tailscale.serve.simple-todo.port = cfg.port;
        };
      };
  };
}
