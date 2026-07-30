{ self, lib, ... }: {
  flake.homeModules.quickshell =
    {
      config,
      settings,
      pkgs,
      ...
    }:
    {
      imports = lib.optionals (settings.desktop != null) [ ];
      config = lib.mkIf (settings.desktop != null) {
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
