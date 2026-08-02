{ self, lib, ... }: {
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
          upower
          bluez
        ];
        home.sessionVariables.QUICKSHELL_MACHINE = settings.hostname;
        xdg.configFile."quickshell".source = ../dotfiles/quickshell;
      };
    };
}
