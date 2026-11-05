{ lib, ... }: {
  options.flake.sshHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          hostname = lib.mkOption { type = lib.types.str; };
          port = lib.mkOption {
            type = lib.types.port;
            default = 2222;
          };
          user = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
    default = { };
    description = "SSH endpoints, including non-NixOS machines.";
  };
  options.flake.machines = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          key = lib.mkOption {
            type = lib.types.str;
            description = "Age recipient SSH public key.";
          };
          tailscale.ip = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
          syncthing.id = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
          };
        };
      }
    );
    default = { };
    description = "Typed fleet inventory shared by service integrations.";
  };
}
