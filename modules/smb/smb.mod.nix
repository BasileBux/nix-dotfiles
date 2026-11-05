{ self, ... }: {
  flake.module.smb = {
    imports = [ self.flakeModules.secrets ];
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        options.my.smb = lib.mkOption {
          type = lib.types.submodule {
            options = {
              host = lib.mkOption {
                type = lib.types.str;
                description = "The SMB server host";
              };
              destination = lib.mkOption {
                type = lib.types.str;
                default = "/home";
                description = "The SMB share destination on the server (e.g. /home)";
              };
              mountPoint = lib.mkOption {
                type = lib.types.str;
                default = "/home/${config.my.settings.username}/synology";
                description = "The local mount point for the share";
              };
              uid = lib.mkOption {
                type = lib.types.int;
                default =
                  let
                    uid = config.users.users.${config.my.settings.username}.uid;
                  in
                  if uid == null then 1000 else uid;
                description = "UID to map the SMB share to";
              };
              gid = lib.mkOption {
                type = lib.types.int;
                default = config.users.groups.${config.users.users.${config.my.settings.username}.group}.gid;
                description = "GID to map the SMB share to";
              };
              credentials = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Name of the age secret holding the credentials file (path
                  relative to the repo root, e.g. modules/smb/synology.age).
                  It is auto-registered by the secrets module, so it can live
                  under modules/smb/ (user-readable everywhere) or
                  hosts/<host>/ (host-specific).
                '';
              };
            };
          };
          default = { };
          description = "SMB module settings";
        };

        config = {
          my.secrets.requested = lib.mkIf config.my.secrets.enabled [ config.my.smb.credentials ];
          assertions = [
            {
              assertion = config.services.tailscale.enable;
              message = "The SMB tailnet mount requires the tailscale module.";
            }
          ];
          environment.systemPackages = with pkgs; [ cifs-utils ];

          fileSystems.${config.my.smb.mountPoint} = lib.mkIf config.my.secrets.enabled {
            device = "//${config.my.smb.host}${config.my.smb.destination}";
            fsType = "cifs";
            options =
              let
                automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=10s,x-systemd.mount-timeout=5s,soft,retrans=1,x-systemd.requires=tailscaled.service,x-systemd.after=tailscaled.service";
              in
              [
                "${automount_opts},credentials=${
                  config.age.secrets.${config.my.smb.credentials}.path
                },uid=${toString config.my.smb.uid},gid=${toString config.my.smb.gid}"
              ];
          };
        };
      };
  };
}
