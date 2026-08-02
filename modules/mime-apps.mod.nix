{ self, lib, ... }: {
  flake.homeModules.mime-apps = { config, settings, ... }: {
    imports = [ ];
    config = {
      xdg.desktopEntries.nvim-terminal = {
        name = "Neovim";
        comment = "Edit text files in Neovim (terminal)";
        exec = "kitty -e nvim %F";
        terminal = false; # kitty itself is the terminal being launched; this is not the flag you set to true
        icon = "nvim";
        type = "Application";
        mimeType = [
          "text/plain"
          "text/markdown"
        ];
        categories = [
          "Utility"
          "TextEditor"
        ];
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/markdown" = "nvim-terminal.desktop";
          "text/plain" = "nvim-terminal.desktop";
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
        };
      };
    };
  };
}
