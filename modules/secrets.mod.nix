# Based almost verbatim on RGBCube's age/secrets config
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed

{
  inputs,
  lib,
  ...
}:
let
  inherit (lib.modules)
    mkAliasOptionModule
    mkDefault
    mkIf
    mkMerge
    ;
  inherit (lib.strings) hasPrefix;

  # Load auto-discovery data
  discoveredSecrets = import ../secrets.nix;

  # Module secrets (paths starting with "modules/") → user-readable
  moduleSecretNames = builtins.filter (hasPrefix "modules/") (builtins.attrNames discoveredSecrets);
in
{
  flake.nixosModules.secrets =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        (mkAliasOptionModule [ "secrets" ] [ "age" "secrets" ])
        inputs.agenix.nixosModules.age
      ];

      config = mkMerge [
        {
          # Avoid cycle with ssh host key generation
          age.identityPaths = mkDefault [ ];
        }

        # Register all discovered secrets with their file paths
        {
          age.secrets = builtins.mapAttrs (_: v: { file = v.file; }) discoveredSecrets;
        }

        # Module secrets: make them readable by the primary user
        (mkIf (config ? my.settings.username) {
          age.secrets = builtins.listToAttrs (
            map (name: {
              inherit name;
              value = {
                owner = config.my.settings.username;
                group = "users";
                mode = "0400";
              };
            }) moduleSecretNames
          );
        })

        # Conditionally mount /media/key if any identity path references it
        (mkIf (config.age.identityPaths |> builtins.any (hasPrefix "/media/key/")) {
          boot.initrd.availableKernelModules = {
            exfat = true;
            usb_storage = true;
            uas = true;
          };

          fileSystems."/media/key" = {
            device = "/dev/disk/by-label/${config.networking.hostName}.s";
            fsType = "exfat";
            options = [
              "ro"
              "umask=0077"
            ];
            neededForBoot = true;
          };
        })
      ];
    };

  flake.homeModules.secrets =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.ragenix
        pkgs.age
      ];
    };
}
