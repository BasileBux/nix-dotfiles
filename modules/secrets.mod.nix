{ inputs, ... }:
let
  discovered = import ../secrets.nix;
  policy = import ./secrets/policy.nix;
in
{
  flake.module.secrets = {
    nixos =
      { config, lib, ... }:
      let
        cfg = config.my.secrets;
        host = config.networking.hostName;
        selected = lib.filterAttrs (
          name: _: lib.hasPrefix "hosts/${host}/" name || (cfg.enabled && builtins.elem name cfg.requested)
        ) discovered;
      in
      {
        imports = [
          inputs.agenix.nixosModules.age
          (lib.mkAliasOptionModule [ "secrets" ] [ "age" "secrets" ])
        ];
        options.my.secrets = {
          enabled = lib.mkOption {
            type = lib.types.bool;
            readOnly = true;
            default = config.age.identityPaths != [ ];
            description = "Whether identities are configured; this does not prove decryptability.";
          };
          requested = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Shared secrets explicitly requested by enabled consumers.";
          };
        };
        config = lib.mkMerge [
          {
            age.identityPaths = lib.mkDefault [ ];
            age.secrets = lib.mapAttrs (
              name: value:
              {
                file = value.file;
              }
              // lib.optionalAttrs (policy ? ${name}) {
                owner =
                  if policy.${name}.owner == "primary-user" then
                    config.my.settings.username
                  else
                    policy.${name}.owner;
                mode = "0400";
              }
            ) selected;
            assertions = [
              {
                assertion = selected == { } || cfg.enabled;
                message = ''
                  ${host} has age secrets registered (hosts/${host}/*.age) but no age
                  identity path, so they cannot be decrypted.
                  Either give this host an identity (a key in
                  hosts/${host}/identity.nix, or ageIdentityPaths in its .mod.nix),
                  or remove the secrets under hosts/${host}/.
                '';
              }
            ]
            ++ map (name: {
              assertion = policy ? ${name} && discovered ? ${name} && builtins.elem host policy.${name}.hosts;
              message = "Secret ${name} is missing or its explicit policy does not authorize ${host}.";
            }) (lib.unique cfg.requested);
          }
          (lib.mkIf (lib.any (lib.hasPrefix "/media/key/") config.age.identityPaths) {
            boot.initrd.availableKernelModules = [
              "exfat"
              "usb_storage"
              "uas"
            ];
            fileSystems."/media/key" = {
              device = "/dev/disk/by-label/${host}.s";
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
    home = { pkgs, ... }: {
      home.packages = [
        pkgs.ragenix
        pkgs.age
      ];
    };
  };
}
