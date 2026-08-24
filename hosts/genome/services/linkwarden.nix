{ config, pkgs, ... }:

let
  gs = config.my.genomeServices;
  linkwarden = pkgs.callPackage ../../../packages/linkwarden { };
in
{
  services.meilisearch = {
    enable = true;
    listenAddress = "127.0.0.1";
    listenPort = gs.ports.meilisearch;
    masterKeyFile = gs.secrets.meiliMasterKey;
  };

  services.postgresql.enable = true;

  services.linkwarden = {
    enable = true;
    package = linkwarden;

    host = "127.0.0.1";
    port = gs.ports.linkwarden;

    enableRegistration = true;

    environment = {
      NEXTAUTH_URL = "https://linkwarden.${gs.tailnetDomain}";
      MEILI_HOST = "http://127.0.0.1:${toString gs.ports.meilisearch}";
      NEXT_PUBLIC_CREDENTIALS_ENABLED = "true";
    };

    secretFiles = {
      NEXTAUTH_SECRET = gs.secrets.nextauth;
      MEILI_MASTER_KEY = gs.secrets.meiliMasterKey;
    };
  };
}
