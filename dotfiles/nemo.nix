{ ... }:

{
  dconf.enable = true;
  dconf.settings = {
    "org/nemo/preferences" = {
      # Single click to open
      click-policy = "single";
      # Show hidden files
      show-hidden-files = true;
      # ISO date format
      date-format = "iso";
      # Show advanced permissions in properties
      show-advanced-permissions = true;
      # Show path in title bar
      show-full-path-titles = true;
      # Show extra pane toggle in toolbar
      show-toggle-extra-pane-toolbar = true;
      # Base-10 size prefixes (kB, MB vs kiB, MiB)
      size-prefixes = "base-10";
      # Disable tooltips in icon view (can be noisy)
      tooltips-in-icon-view = false;
      tooltips-in-list-view = false;

      executable-text-activation = "ask";
    };

    "org/nemo/window-state" = {
      # Start with sidebar open at a reasonable width
      start-with-sidebar = true;
      sidebar-width = 200;
      side-pane-view = "places";
    };

    "org/cinnamon/desktop/applications/terminal" = {
      exec = "kitty";
    };
  };
}
