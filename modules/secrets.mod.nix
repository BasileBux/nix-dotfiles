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
  flake.module.secrets = {
    nixos =
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

        options.my.secrets.enabled = lib.mkOption {
          type = lib.types.bool;
          readOnly = true;
          default = config.age.identityPaths != [ ];
          description = ''
            Whether this host participates in age secrets, i.e. has at least one
            age identity path configured. Derived from age.identityPaths: hosts
            without identity paths (e.g. machines used by people without the
            private keys) simply don't get module secrets, and everything that
            consumes them is disabled.
          '';
        };

        config = mkMerge [
          {
            # Avoid cycle with ssh host key generation. This also keeps
            # age.identityPaths exactly what the host operator declared: agenix
            # would otherwise default it from services.openssh.hostKeys, which
            # would silently enable secrets on openssh hosts without user keys.
            age.identityPaths = mkDefault [ ];
          }

          # Register secrets. Host secrets (hosts/<host>/*.age) are always
          # registered; they only exist for hosts that own them. Module secrets
          # (modules/**/*.age) are only registered when this host has an age
          # identity: without one they can't be decrypted, and registering them
          # would trip agenix's eval-time assertion (age.identityPaths must be
          # set) or fail activation.
          {
            age.secrets =
              let
                hostPrefix = "hosts/${config.networking.hostName}/";
              in
              builtins.mapAttrs (_: v: { file = v.file; }) (
                lib.filterAttrs (
                  name: _:
                  lib.hasPrefix hostPrefix name
                  || (config.my.secrets.enabled && !(lib.hasPrefix "hosts/" name))
                ) discoveredSecrets
              );
          }

          # Module secrets: make them readable by the primary user. Gated on
          # my.secrets.enabled so that keyless hosts don't end up with
          # age.secrets entries lacking a `file` (which would re-trigger
          # agenix's identityPaths assertion).
          (mkIf (config.my.secrets.enabled && config ? my.settings.username) {
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

          # Fail loudly if secrets are registered but no identity can decrypt
          # them. Only reachable with host secrets (hosts/<host>/*.age): module
          # secrets are already gated on my.secrets.enabled above.
          {
            assertions = [
              {
                assertion = config.age.secrets == { } || config.age.identityPaths != [ ];
                message = ''
                  This host has age secrets registered (hosts/${config.networking.hostName}/)
                  but no age identity path, so they cannot be decrypted.
                  Either set ageIdentityPaths in hosts/<host>/<host>.mod.nix, e.g.
                  ageIdentityPaths = [ "/home/<user>/.ssh/<host>" ];
                  or remove the secrets under hosts/<host>/.
                '';
              }
            ];
          }

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

    home =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.ragenix
          pkgs.age
        ];
      };
  };
}
