{ config, ... }:
{
  my.services.vaultwarden.envFile = config.age.secrets."hosts/genome/vaultwarden.env.age".path;

  my.services.linkwarden.secretFiles = {
    nextauth = config.age.secrets."hosts/genome/nextauth-secret.age".path;
    meiliMasterKey = config.age.secrets."hosts/genome/meili-master-key.age".path;
  };

  users.users.${config.my.settings.username}.extraGroups = [ "media" ];

  # Tailscale SSH as an emergency backdoor.
  services.tailscale.extraSetFlags = [ "--ssh=true" ];

  # Secrets read by a service process need their owner declared; env files
  # consumed by systemd itself stay root-owned.
  age.secrets."hosts/genome/nextauth-secret.age" = {
    owner = "linkwarden";
    group = "linkwarden";
    mode = "0400";
  };

  age.secrets."hosts/genome/meili-master-key.age" = {
    owner = "linkwarden";
    group = "linkwarden";
    mode = "0400";
  };
}
