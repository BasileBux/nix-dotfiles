{ lib, ... }:
let
  userModule =
    { config, pkgs, ... }:
    let
      username = config.my.settings.username;
      hostname = config.networking.hostName;
      secretName = "hosts/${hostname}/${username}.age";
      hasPassword = config.age.secrets ? "${secretName}";
    in
    {
      users.users.${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        shell = pkgs.nushell;
        ignoreShellProgramCheck = true;
      }
      // lib.optionalAttrs hasPassword {
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
