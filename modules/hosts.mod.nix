# Exposes the fleet inventory. Fleet-wide constants come from fleet.nix, per-host
# data from hosts/<host>/identity.nix via hosts/default.nix.
{ ... }:
let
  fleet = import ../fleet.nix;
  inventory = import ../hosts;
in
{
  flake = {
    inherit fleet;
    inherit (fleet)
      people
      tailnet
      externalHosts
      keys-admin
      syncthing
      ;
    inherit (inventory) hosts machines sshHosts;
  };
}
