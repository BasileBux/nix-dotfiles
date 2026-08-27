# genome's tailscale declaration.
#
# Declarative parts (native nixpkgs 26.05 options):
# - useRoutingFeatures: genome consumes a Mullvad exit node -> rp_filter loose
# - openFirewall: allow inbound UDP 41641 for direct (non-DERP) connections
# - extraSetFlags: enables Tailscale SSH (emergency backdoor bypassing sshd)
#   via the generated tailscaled-set.service (ordered after re-auth)
#
# Serve is intentionally NOT using services.tailscale.serve (as of tailscale
# 1.98.10): the services-config format derives the serve type from the
# *destination* scheme, so "http://" serves plain HTTP on 443 (no TLS),
# "https://" proxies to the upstream *over TLS* (our services are plain HTTP
# locally), and "tls-terminated-tcp://" is rejected by set-config's target
# validation. None of these express "terminate TLS on 443 with tailscale's
# cert, proxy to plain-HTTP upstream" — which the CLI's `--https=443` does.
# If that ever changes upstream, migrate to services.tailscale.serve.services.
#
# The unit does `serve reset` first so the apply is truly declarative (the
# CLI refuses to change an existing port's serve type in place).
#
# Exit-node selection is runtime state, managed by hand: genome uses
# `tailscale set --auto-exit-node` (Mullvad rotates/retires nodes constantly,
# so never pin a hostname; see genome-reinstall.md, 2026-08-27 incident).
# Note: the STATUS column in `tailscale exit-node list` is unreliable for
# Mullvad nodes (they don't answer disco probes) — verify with real traffic,
# e.g. `curl https://am.i.mullvad.net/ip`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  gs = config.my.genomeServices;
  ts = config.services.tailscale.package;

  # The five services exposed on the tailnet — explicitly listed so that
  # internal ports in gs.ports (meilisearch, torrentPeers) stay internal.
  exposedServices = {
    vaultwarden = gs.ports.vaultwarden;
    linkwarden = gs.ports.linkwarden;
    jellyfin = gs.ports.jellyfin;
    qbittorrent = gs.ports.qbittorrent;
    upsnap = gs.ports.upsnap;
  };

  toProxy = name: port: ''
    ${lib.getExe ts} serve --service=svc:${name} --https=443 http://127.0.0.1:${toString port}
  '';
in
{
  services.tailscale.useRoutingFeatures = "client";
  services.tailscale.openFirewall = true;

  services.tailscale.extraSetFlags = [ "--ssh=true" ];

  systemd.services.tailscale-serve = {
    description = "Advertise the service stack through tailscale serve";
    after = [
      "network-online.target"
      "tailscaled.service"
      "tailscaled-set.service"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tailscale-serve-genome" (
        lib.concatStringsSep "\n" (
          [
            ''
              set -euo pipefail
              # CLI refuses to flip a port's serve type in place -> start clean.
              ${lib.getExe ts} serve reset >/dev/null
            ''
          ]
          ++ lib.mapAttrsToList toProxy exposedServices
        )
      );
    };
  };
}
