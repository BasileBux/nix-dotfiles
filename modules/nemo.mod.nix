{ self, lib, ... }: {
  flake.homeModules.nemo = { config, settings, ... }: {
    imports = lib.optionals (settings.desktop != null) [ ];
    config = lib.mkIf (settings.desktop != null) {
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
    };
  };
}
