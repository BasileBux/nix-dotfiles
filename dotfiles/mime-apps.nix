let
  browser = "helium"; # zen-twilight
  textEditor = "neovide";
  imageViewer = "org.kde.gwenview";
  videoPlayer = "mpv";
  pdfViewer = "org.gnome.Evince";
in
{
  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "${browser}.desktop";
      "text/markdown" = "${textEditor}.desktop";
      "text/plain" = "${textEditor}.desktop";

      "image/png" = "${imageViewer}.desktop";
      "image/jpeg" = "${imageViewer}.desktop";
      "image/gif" = "${imageViewer}.desktop";
      "image/webp" = "${imageViewer}.desktop";
      "application/pdf" = "${pdfViewer}.desktop";

      "video/mp4" = "${videoPlayer}.desktop";
      "video/webm" = "${videoPlayer}.desktop";
      "video/x-matroska" = "${videoPlayer}.desktop";

      "audio/mpeg" = "${videoPlayer}.desktop";
      "audio/flac" = "${videoPlayer}.desktop";
      "audio/ogg" = "${videoPlayer}.desktop";

      "x-scheme-handler/http" = "${browser}.desktop";
      "x-scheme-handler/https" = "${browser}.desktop";
      "x-scheme-handler/about" = "${browser}.desktop";
      "x-scheme-handler/unknown" = "${browser}.desktop";
    };
  };
}
