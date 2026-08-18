{
  flake.module.smb = {
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        environment.systemPackages = with pkgs; [ cifs-utils ];
        fileSystems."/home/${config.my.settings.username}/synology" = lib.mkIf config.my.secrets.enabled {
          device = "//100.86.179.75/home";
          fsType = "cifs";
          options =
            let
              automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=10s,x-systemd.mount-timeout=5s,soft,retrans=1,x-systemd.requires=tailscaled.service,x-systemd.after=tailscaled.service";
            in
            [
              "${automount_opts},credentials=${
                config.age.secrets."modules/smb/credentials.age".path
              },uid=1000,gid=100"
            ];
        };
      };
  };
}
