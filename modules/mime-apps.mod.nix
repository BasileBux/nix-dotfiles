{ self, lib, ... }: {
  flake.homeModules.mime-apps = { config, settings, ... }: {
    imports = lib.optionals (settings.desktop) [ ];
    config = lib.mkIf (settings.desktop) {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "helium.desktop";
          "text/markdown" = "neovide.desktop";
          "text/plain" = "neovide.desktop";
          "image/png" = "org.kde.gwenview.desktop";
          "image/jpeg" = "org.kde.gwenview.desktop";
          "image/gif" = "org.kde.gwenview.desktop";
          "image/webp" = "org.kde.gwenview.desktop";
          "application/pdf" = "org.gnome.Evince.desktop";
          "video/mp4" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "audio/mpeg" = "mpv.desktop";
          "audio/flac" = "mpv.desktop";
          "audio/ogg" = "mpv.desktop";
          "inode/directory" = "nemo.desktop";
          "x-scheme-handler/http" = "helium.desktop";
          "x-scheme-handler/https" = "helium.desktop";
          "x-scheme-handler/about" = "helium.desktop";
          "x-scheme-handler/unknown" = "helium.desktop";
        };
      };
    };
  };
}
