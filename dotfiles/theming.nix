{
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    dconf
    gsettings-desktop-schemas
    glib
    gnome-themes-extra
    libnotify # Important for notifications to work
  ];

  # Qt theming to match GTK
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
    style.package = pkgs.libsForQt5.qtstyleplugins;
  };

  # Environment variables for dark theme
  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };

  # XDG desktop portal for proper theming
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      };
    };
  };
}
