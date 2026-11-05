{ lib, ... }:
let
  fleet = import ../fleet.nix;
  types = import ../lib/fleet-types.nix {
    inherit lib;
    defaults = fleet.defaults;
  };
in
{
  options.flake.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf types.identity;
    default = { };
    description = "Raw per-host declarations from hosts/<host>/identity.nix.";
  };
  options.flake.machines = lib.mkOption {
    type = types.machines;
    default = { };
    description = "Typed, resolved fleet inventory shared by service integrations.";
  };
  options.flake.sshHosts = lib.mkOption {
    type = lib.types.attrsOf types.endpoint;
    default = { };
    description = "SSH endpoints derived from managed and external fleet hosts.";
  };
  options.flake."keys-admin" = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Admin age co-recipients and authorized_keys entries.";
  };
}
