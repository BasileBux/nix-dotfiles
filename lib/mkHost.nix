{ inputs, lib }:
{
  hostName,
  system ? "x86_64-linux",
  settings,
  homeModules ? [ ],
  extraModules ? [ ],
}:
let
  settings' = settings;
  secrets = if builtins.pathExists ../secrets.nix then import ../secrets.nix else { };
  hardwarePath = ../hosts/${hostName}/hardware-configuration.nix;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit
      inputs
      secrets
      ;
    settings = settings';
  };
  modules = [
    inputs.self.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs secrets; settings = settings'; };
      home-manager.users.${settings'.username} = {
        imports = [ inputs.self.homeModules.default ] ++ homeModules;
        home.stateVersion = settings.nixosVersion;
      };
    }
    {
      networking.hostName = settings'.hostname;
      system.stateVersion = settings'.nixosVersion;
      my.settings = settings';
    }
  ]
  ++ extraModules
  ++ lib.optional (builtins.pathExists hardwarePath) hardwarePath;
}
