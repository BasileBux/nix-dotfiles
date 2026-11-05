# Aggregates hosts/<host>/identity.nix into the fleet inventory exposed as
# flake.hosts / flake.machines / flake.sshHosts. Every directory under hosts/
# must carry an identity.nix; it may be `{ }` for a host that holds no secrets
# and needs no overrides.
#
# Builtins only: secrets.nix imports this without a nixpkgs lib.
let
  fleet = import ../fleet.nix;
  inherit (builtins)
    attrNames
    filter
    listToAttrs
    map
    mapAttrs
    pathExists
    readDir
    ;

  entries = readDir ./.;
  dirs = filter (name: entries.${name} == "directory") (attrNames entries);
  identityPath = name: ./. + "/${name}/identity.nix";

  hosts = listToAttrs (
    map (name: {
      inherit name;
      value =
        if pathExists (identityPath name) then
          import (identityPath name)
        else
          throw "hosts/${name}: missing identity.nix (use `{ }` when the host needs no overrides and holds no secrets)";
    }) dirs
  );

  # Explicit defaults rather than option defaults, so the result is the same
  # whether the input is a raw identity.nix or a normalized (null-filled) one.
  orDefault = fallback: value: if value == null then fallback else value;

  resolve =
    name: host:
    let
      username = orDefault fleet.defaults.username (host.username or null);
      ssh = host.ssh or { };
    in
    {
      inherit username;
      key = host.key or null;
      tailscale.ip = host.tailscale.ip or null;
      syncthing.id = host.syncthing.id or null;
      ssh = {
        hostname = orDefault "${name}.${fleet.tailnet.domain}" (ssh.hostname or null);
        port = orDefault fleet.defaults.ssh.port (ssh.port or null);
        user = orDefault username (ssh.user or null);
      };
    };

  machines = mapAttrs resolve hosts;
in
{
  inherit hosts machines resolve;

  # Managed machines plus the endpoints that are not NixOS hosts (the NAS).
  sshHosts = mapAttrs (_: machine: machine.ssh) (machines // fleet.externalHosts);
}
