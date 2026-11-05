{ lib, ... }:
let
  userModule =
    { config, pkgs, ... }:
    let
      secretName = "hosts/${config.networking.hostName}/password.age";
    in
    {
      users.users.${config.my.settings.username} = {
        isNormalUser = true;
        home = config.my.settings.homeDirectory;
        extraGroups = [ "wheel" ];
      }
      // lib.optionalAttrs (config.age.secrets ? "${secretName}") {
        hashedPasswordFile = config.age.secrets.${secretName}.path;
      };
    };
in
{
  flake.module.users = {
    nixos = userModule;
  };
}
