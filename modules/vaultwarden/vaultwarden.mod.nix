{
  ...
}:
{
  flake.module.vaultwarden = {
    nixos =
      { config, lib, ... }:
      let
        cfg = config.my.services.vaultwarden;
      in
      {
        options.my.services.vaultwarden = {
          enable = lib.mkEnableOption "Vaultwarden password manager (served on the tailnet)";

          port = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            description = "Loopback port for the web UI/API";
          };

          envFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to a KEY=VALUE environment file (agenix), at minimum
              ADMIN_TOKEN. Expected to live at hosts/<host>/vaultwarden.env.age
              so only that host can decrypt it.
            '';
          };

          signupsAllowed = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to allow new account signups";
          };
        };

        config = lib.mkIf cfg.enable (
          lib.mkMerge [
            {
              assertions = [
                {
                  assertion = cfg.envFile != null;
                  message = ''
                    my.services.vaultwarden.envFile is required: create
                    hosts/<host>/vaultwarden.env.age (at minimum ADMIN_TOKEN=...),
                    rekey (ragenix --rules ./secrets.nix --rekey -i ~/.ssh/<host>),
                    then set
                      envFile = config.age.secrets."hosts/<host>/vaultwarden.env.age".path;
                  '';
                }
              ];

              services.vaultwarden = {
                enable = true;
                config = {
                  DOMAIN = "https://vaultwarden.${config.my.tailscale.tailnetDomain}";
                  ROCKET_ADDRESS = "127.0.0.1";
                  ROCKET_PORT = cfg.port;
                  ENABLE_WEBSOCKET = true;
                  SIGNUPS_ALLOWED = lib.mkDefault cfg.signupsAllowed;

                  BACKUP_ENABLED = lib.mkDefault true;
                  BACKUP_SCHEDULE = lib.mkDefault "0 0 4 * * *";
                  BACKUP_RETENTION_DAYS = lib.mkDefault 30;
                  BACKUP_TIMEZONE = lib.mkDefault "Europe/Zurich";
                };
              };

              my.services.ports.vaultwarden = cfg.port;
              my.tailscale.serve.vaultwarden.port = cfg.port;
            }

            (lib.mkIf (cfg.envFile != null) {
              services.vaultwarden.environmentFile = [ cfg.envFile ];
            })
          ]
        );
      };
  };
}
