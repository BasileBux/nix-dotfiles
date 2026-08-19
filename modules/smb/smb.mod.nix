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
                default = 1000;
                description = "UID to map the SMB share to";
              };
              gid = lib.mkOption {
                type = lib.types.int;
                default = 100;
                description = "GID to map the SMB share to";
              };
            };
          };
          default = { };
          description = "SMB module settings";
        };

        config = {
          environment.systemPackages = with pkgs; [ cifs-utils ];

          fileSystems.${config.my.smb.mountPoint} = lib.mkIf config.my.secrets.enabled {
            device = "//${config.my.smb.host}/${lib.removePrefix "/" config.my.smb.destination}";
            fsType = "cifs";
            options =
              let
                automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=10s,x-systemd.mount-timeout=5s,soft,retrans=1,x-systemd.requires=tailscaled.service,x-systemd.after=tailscaled.service";
              in
              [
                "${automount_opts},credentials=${
                  config.age.secrets."modules/smb/credentials.age".path
                },uid=${toString config.my.smb.uid},gid=${toString config.my.smb.gid}"
              ];
          };
        };
      };
  };
}
