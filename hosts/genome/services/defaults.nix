{ lib, config, ... }:

let
  ports = {
    vaultwarden = 8080;
    linkwarden = 3000;
    jellyfin = 8096;
    qbittorrent = 8081;
    upsnap = 9090;
    meilisearch = 7700;
    torrentPeers = 51413;
  };

  tailnetDomain = "tail7925e1.ts.net";

  secret = name: config.age.secrets."hosts/genome/${name}".path;
in
{
  options.my.genomeServices = lib.mkOption {
    type = lib.types.submodule {
      options = {
        tailnetDomain = lib.mkOption {
          type = lib.types.str;
          default = tailnetDomain;
        };
        ports = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = ports;
        };
        secrets = lib.mkOption {
          type = lib.types.attrsOf lib.types.path;
          default = { };
        };
      };
    };
  };

  config.my.genomeServices = {
    inherit tailnetDomain ports;
    secrets = {
      vaultwardenEnv = secret "vaultwarden.env.age";
      nextauth = secret "nextauth-secret.age";
      meiliMasterKey = secret "meili-master-key.age";
      qbittorrentEnv = secret "qbittorrent.env.age";
    };
  };
}
