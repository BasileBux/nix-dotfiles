{ config, lib, ... }:

let
  gs = config.my.genomeServices;
  ts = config.services.tailscale.package;
in
{
  systemd.services.tailscale-serve = {
    description = "Advertise the service stack through tailscale serve";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "15s";
    };

    script = ''
      ${lib.getExe ts} serve --service=svc:vaultwarden --https=443 http://127.0.0.1:${toString gs.ports.vaultwarden}
      ${lib.getExe ts} serve --service=svc:linkwarden  --https=443 http://127.0.0.1:${toString gs.ports.linkwarden}
      ${lib.getExe ts} serve --service=svc:jellyfin    --https=443 http://127.0.0.1:${toString gs.ports.jellyfin}
      ${lib.getExe ts} serve --service=svc:qbittorrent --https=443 http://127.0.0.1:${toString gs.ports.qbittorrent}
      ${lib.getExe ts} serve --service=svc:upsnap      --https=443 http://127.0.0.1:${toString gs.ports.upsnap}
    '';
  };
}
