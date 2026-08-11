# Nixos config

This is my personal NixOS configuration.

## Installation

To install it, you need to create a new host in the `hosts` directory. Do the following:

```bash
nix-shell -p git
git clone https://github.com/BasileBux/nix-dotfiles.git nixos
cd nixos
# Create a new host
mkdir hosts/<hostname>
touch hosts/<hostname>/<hostname>.nix
sudo cp /etc/nixos/hardware-configuration.nix hosts/<hostname>
```

Then, in the `<hostname>.nix` file

```nix
{ lib, inputs, ... }:
{
  flake.nixosConfigurations.john (import ../../lib/mkHost.nix { inherit inputs lib; }) rec {
    settings = {
      username = "doe";
      hostname = "john";
      nixosVersion = "26.05";
      gitName = "john doe";
      gitEmail = "john.doe@example.com";
    };
    hostName = settings.hostname;
    system = "x86_64-linux";
    ageIdentityPaths = [ "path/to/ssh/key" ];

    homeModules = [ ];
    extraModules = [ ];
  };
}
```

And then rebuild with:
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Credits

This config underwent a big rewrite to match the dentride structure, based on
[RGBCube's ncc](https://github.com/RGBCube/ncc/tree/dentride) (MIT licensed).

- The module auto-discovery mechanism was conceptually inspired by ncc, then adapted
    for my own module set.
- The age/secrets configuration is copied almost verbatim from ncc, with only minor
    adjustments.
- The nushell prompt and some of the configs are copied from ncc, with only minor
    adjustments.

Given how much of this repo derives from ncc, this repo is also licensed MIT.
