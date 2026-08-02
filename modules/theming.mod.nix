{ self, lib, ... }: {
  flake.homeModules.theming =
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
          dconf
          gsettings-desktop-schemas
          glib
          gnome-themes-extra
          libnotify
        ];
        dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        qt = {
          enable = true;
          platformTheme.name = "kde";
          style.name = "breeze";
          style.package = pkgs.libsForQt5.qtstyleplugins;
        };
        home.sessionVariables.GTK_THEME = "Adwaita:dark";
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
          config.common = {
            default = [ "hyprland" ];
            "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          };
        };
      };
    };
}
