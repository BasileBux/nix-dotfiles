{
  ...
}:
{
  flake.module.linkwarden = {
    nixos =
      {
        inputs,
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.my.services.linkwarden;
      in
      {
        options.my.services.linkwarden = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable Linkwarden bookmark manager (served on the tailnet)";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = "Loopback port for the web UI";
          };

          meilisearchPort = lib.mkOption {
            type = lib.types.port;
            default = 7700;
            description = "Loopback port of the internal Meilisearch instance";
          };

          secretFiles = lib.mkOption {
            type = lib.types.submodule {
              options = {
                nextauth = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = ''
                    Path to the NextAuth secret (agenix), e.g.
                    config.age.secrets."hosts/<host>/nextauth-secret.age".path.
                    Must be readable by the linkwarden service user.
                  '';
                };
                meiliMasterKey = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                  description = ''
                    Path to the Meilisearch master key (agenix), read by both
                    Meilisearch and Linkwarden. Must be readable by the
                    linkwarden service user.
                  '';
                };
              };
            };
            default = { };
          };

          enableRegistration = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to allow new account signups";
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.secretFiles.nextauth != null;
              message = ''
                my.services.linkwarden.secretFiles.nextauth is required:
                create hosts/<host>/nextauth-secret.age
                (openssl rand -base64 32 | ragenix -e --name hosts/<host>/nextauth-secret.age),
                rekey, declare its owner as the linkwarden user, then set
                  secretFiles.nextauth = config.age.secrets."hosts/<host>/nextauth-secret.age".path;
              '';
            }
            {
              assertion = cfg.secretFiles.meiliMasterKey != null;
              message = ''
                my.services.linkwarden.secretFiles.meiliMasterKey is required:
                create hosts/<host>/meili-master-key.age
                (openssl rand -base64 32 | ragenix -e --name hosts/<host>/meili-master-key.age),
                rekey, declare its owner as the linkwarden user, then set
                  secretFiles.meiliMasterKey = config.age.secrets."hosts/<host>/meili-master-key.age".path;
              '';
            }
          ];

          services.meilisearch = {
            enable = true;
            listenAddress = "127.0.0.1";
            listenPort = cfg.meilisearchPort;
            masterKeyFile = cfg.secretFiles.meiliMasterKey;
          };

          services.postgresql.enable = true;

          services.linkwarden = {
            enable = true;
            package = pkgs.callPackage (inputs.self + "/packages/linkwarden") { };

            host = "127.0.0.1";
            port = cfg.port;
            enableRegistration = cfg.enableRegistration;

            environment = {
              NEXTAUTH_URL = "https://linkwarden.${config.my.tailscale.tailnetDomain}";
              MEILI_HOST = "http://127.0.0.1:${toString cfg.meilisearchPort}";
              NEXT_PUBLIC_CREDENTIALS_ENABLED = "true";
            };

            secretFiles = {
              NEXTAUTH_SECRET = cfg.secretFiles.nextauth;
              MEILI_MASTER_KEY = cfg.secretFiles.meiliMasterKey;
            };
          };

          my.services.ports.linkwarden = cfg.port;
          my.services.ports.linkwarden-meilisearch = cfg.meilisearchPort;
          my.tailscale.serve.linkwarden.port = cfg.port;
        };
      };
  };
}
