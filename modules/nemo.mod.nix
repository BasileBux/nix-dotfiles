{
  self,
  lib,
  pkgs,
  ...
}:
{
  flake.homeModules.desktop = self.homeModules.nemo;
  flake.homeModules.nemo = { config, pkgs, ... }: {
    imports = [ ];
    config = {
      home.packages = [
        pkgs.nemo
      ];
      dconf.enable = true;
      dconf.settings = {
        "org/nemo/preferences" = {
          click-policy = "single";
          show-hidden-files = true;
          date-format = "iso";
          show-advanced-permissions = true;
          show-full-path-titles = true;
          show-toggle-extra-pane-toolbar = true;
          size-prefixes = "base-10";
          tooltips-in-icon-view = false;
          tooltips-in-list-view = false;
          executable-text-activation = "ask";
        };
        "org/nemo/window-state" = {
          start-with-sidebar = true;
          sidebar-width = 200;
          side-pane-view = "places";
        };
        "org/cinnamon/desktop/applications/terminal".exec = "kitty";
      };
      xdg.mimeApps.defaultApplications = {
        "inode/directory" = "nemo.desktop";
      };
    };
  };

  flake.nixosModules.desktop = self.nixosModules.nemo;
  flake.nixosModules.nemo = { config, pkgs, ... }: {
    services.gvfs.enable = true;
    services.udisks2.enable = true;
  };
}
