{ self, lib, ... }: {
  flake.homeModules.desktop = self.homeModules.quickshell;
  flake.homeModules.quickshell =
    {
      config,
      settings,
      pkgs,
      ...
    }:
    {
      imports = [ ];
      config = {
        home.packages = with pkgs; [
          quickshell
          kdePackages.qt5compat
          bluez
        ];
        home.sessionVariables.QUICKSHELL_MACHINE = settings.hostname;
        xdg.configFile."quickshell".source = ../dotfiles/quickshell;
      };
    };

  flake.nixosModules.desktop = self.nixosModules.quickshell;
  flake.nixosModules.quickshell = { config, pkgs, ... }: {
    services.upower.enable = true;
  };
}
