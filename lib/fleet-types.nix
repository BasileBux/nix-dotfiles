# Validation types for the fleet inventory. No data lives here: callers pass
# the fleet defaults they want applied (see fleet.nix).
{ lib, defaults }:
let
  endpoint = lib.types.submodule {
    options = {
      hostname = lib.mkOption { type = lib.types.str; };
      port = lib.mkOption {
        type = lib.types.port;
        default = defaults.ssh.port;
      };
      user = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };
in
{
  inherit endpoint;

  # hosts/<host>/identity.nix: everything a host declares to the rest of the
  # fleet. Every field is optional, including the key: a host that holds no
  # secrets does not need to be an age recipient.
  identity = lib.types.submodule {
    options = {
      username = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Login override; defaults to the fleet default username.";
      };
      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Age recipient: SSH public key of the host identity. Required only for
          hosts that own age secrets or appear in a secret policy.
        '';
      };
      tailscale.ip = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      syncthing.id = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      ssh = lib.mkOption {
        type = lib.types.submodule {
          options = {
            hostname = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Defaults to <name>.<tailnet.domain>.";
            };
            port = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
            };
            user = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Defaults to the host's effective primary username.";
            };
          };
        };
        default = { };
      };
    };
  };

  # Resolved inventory entry: same shape as an identity, with defaults filled.
  machines = lib.types.lazyAttrsOf (
    lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          default = defaults.username;
        };
        key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Age recipient, or null for a host that holds no secrets.";
        };
        tailscale.ip = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        syncthing.id = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        ssh = lib.mkOption { type = endpoint; };
      };
    }
  );
}
