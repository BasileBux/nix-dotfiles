{ config, ... }:
let
  userModule = { config, pkgs, ... }: {
    users.users.${config.my.settings.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;
  };
in
{
  config = {
    commonModules.users = userModule;
    flake.nixosModules.users = userModule;
  };
}
