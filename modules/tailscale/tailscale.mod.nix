# Options tier is always imported (via flake.module.default) so service
# modules can always reference my.tailscale.*; the tailscale module is the
# opt-in. Serving uses the CLI instead of the declarative
# services.tailscale.serve because set-config cannot express TLS termination
# on 443 with a plain-HTTP upstream (tailscale#18381, #19724, nixpkgs#530174).
{
  ...
}:
{
  flake.module.tailscale-options = {
    nixos =
      { lib, ... }:
      {
        options.my.tailscale = {
          tailnetDomain = lib.mkOption {
            type = lib.types.str;
            description = ''
              MagicDNS domain of the tailnet, injected by mkHost. Used to
              derive public service URLs (https://<name>.<tailnetDomain>).
            '';
          };

          self = lib.mkOption {
            type =
              with lib.types;
              nullOr (submodule {
                options.ip = lib.mkOption {
                  type = nullOr str;
                  default = null;
                  description = ''
                    This host's static tailscale IP, from
                    flake.machines.<hostname>.tailscale.ip. Only for consumers
                    that structurally need an IP (bind addresses, from=
                    restrictions); prefer MagicDNS names otherwise.
                  '';
                };
              });
            default = null;
            description = "This machine's entry from the machines registry, or null.";
          };

          serve = lib.mkOption {
            type =
              with lib.types;
              attrsOf (submodule {
                options.port = lib.mkOption {
                  type = port;
                  description = ''
                    Local port the service listens on. The service must bind
                    127.0.0.1 (or all loopback); tailscale terminates TLS and
                    proxies to it.
                  '';
                };
              });
            default = { };
            description = ''
              Services to expose on the tailnet: attribute name = service name
              (reachable at https://<name>.<tailnetDomain>), port = local
              loopback port. Inert unless the tailscale module is enabled.
            '';
          };
        };
      };
  };

  flake.module.tailscale = {
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        config = lib.mkMerge [
          {
            services.tailscale.enable = true;
            services.tailscale.useRoutingFeatures = lib.mkDefault "client";
            services.tailscale.openFirewall = lib.mkDefault true;
          }

          (lib.mkIf (config.my.tailscale.serve != { }) {
            systemd.services.tailscale-serve = {
              description = "Advertise registered services through tailscale serve";
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
                ExecStart = pkgs.writeShellScript "tailscale-serve" (
                  lib.concatStringsSep "\n" (
                    [
                      ''
                        set -euo pipefail
                        # CLI refuses to flip a port's serve type in place,
                        # so start clean to keep the apply declarative.
                        ${lib.getExe config.services.tailscale.package} serve reset >/dev/null
                      ''
                    ]
                    ++ lib.mapAttrsToList (
                      name: serve:
                      "${lib.getExe config.services.tailscale.package} serve --service=svc:${name} --https=443 http://127.0.0.1:${toString serve.port}"
                    ) config.my.tailscale.serve
                  )
                );
              };
            };
          })
        ];
      };
  };
}
