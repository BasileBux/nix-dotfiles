{
  pkgs,
  config,
  settings,
  ...
}:

{
  home.packages = with pkgs; [
    quickshell
    kdePackages.qt5compat
    upower
    bluez
  ];

  home.sessionVariables = {
    QUICKSHELL_MACHINE = settings.machine;
  };

  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${settings.configPath}/dotfiles/quickshell";
}
