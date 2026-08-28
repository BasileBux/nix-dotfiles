{
  lib,
  config,
  ...
}:
{
  flake.module.services = {
    nixos =
      { lib, config, ... }:
      {
        options.my.services.ports = lib.mkOption {
          type = lib.types.attrsOf lib.types.port;
          default = { };
          description = ''
            Registry of ports in use by enabled services, keyed by service
            name. Service modules register their ports automatically;
            host-local services should register theirs too. An assertion
            rejects duplicate ports among enabled services.
          '';
        };

        config.assertions =
          let
            byPort = lib.foldl' (
              acc: name:
              let
                port = toString config.my.services.ports.${name};
              in
              acc // { ${port} = (acc.${port} or [ ]) ++ [ name ]; }
            ) { } (builtins.attrNames config.my.services.ports);
            collisions = lib.filterAttrs (_: names: builtins.length names > 1) byPort;
          in
          lib.mapAttrsToList (port: names: {
            assertion = false;
            message = "Port collision: ${lib.concatStringsSep ", " names} all registered port ${port} in my.services.ports";
          }) collisions;
      };
  };
}
