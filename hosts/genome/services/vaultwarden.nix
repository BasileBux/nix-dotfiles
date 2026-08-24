{ config, ... }:

let
  gs = config.my.genomeServices;
in
{
  services.vaultwarden = {
    enable = true;

    config = {
      DOMAIN = "https://vaultwarden.${gs.tailnetDomain}";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = gs.ports.vaultwarden;
      ENABLE_WEBSOCKET = true;
      SIGNUPS_ALLOWED = false;

      # Self-backup (native vaultwarden backup feature).
      BACKUP_ENABLED = true;
      BACKUP_SCHEDULE = "0 0 4 * * *";
      BACKUP_RETENTION_DAYS = 30;
      BACKUP_TIMEZONE = "Europe/Zurich";
    };

    environmentFile = [ gs.secrets.vaultwardenEnv ];
  };
}
