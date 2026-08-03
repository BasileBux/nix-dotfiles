{ config, ... }:
let
  userModule = { config, pkgs, ... }: {
    users.users.${config.my.settings.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
in
{
  config.flake.nixosModules.users = userModule;
}
