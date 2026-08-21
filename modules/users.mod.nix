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
        extraGroups = [ "wheel" ];
        shell = pkgs.nushell;
        ignoreShellProgramCheck = true;
      }
      // lib.optionalAttrs (config.age.secrets ? "${secretName}") {
        hashedPasswordFile = config.age.secrets.${secretName}.path;
      };
      users.defaultUserShell = pkgs.nushell;
    };
in
{
  flake.module.users = {
    nixos = userModule;
  };
}
