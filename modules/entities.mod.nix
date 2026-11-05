{ lib, ... }: {
  flake = import ../lib/inventory.nix { inherit lib; };
}
