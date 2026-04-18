{
  pkgs,
  settings,
  ...
}:
{
  environment.systemPackages = with pkgs; [ cifs-utils ];
  # Create file `~/smb-secrets` and, in it, write:
  # username=
  # password=
  fileSystems."/mnt/synology" = {
    device = "//100.86.179.75/home";
    fsType = "cifs";
    options =
      let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=10s,x-systemd.mount-timeout=10s,x-systemd.requires=tailscaled.service,x-systemd.after=tailscaled.service";
      in
      [ "${automount_opts},credentials=/home/${settings.username}/smb-secrets,uid=1000,gid=100" ];
  };
}
