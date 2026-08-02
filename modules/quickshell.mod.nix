{ self, lib, ... }: {
  flake.homeModules.quickshell =
    {
      config,
      settings,
      pkgs,
      ...
    }:
    {
      imports = lib.optionals (settings.desktop) [ ];
      config = lib.mkIf (settings.desktop) {
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
