{ self, lib, ... }: {

  flake.homeModules.desktop.imports = [
    self.homeModules.video
    self.homeModules.images
    self.homeModules.pdf
  ];

  flake.homeModules.video =
    { pkgs, ... }:
    let
      inherit (lib.trivial) const;
      inherit (lib.attrsets) genAttrs;
      mimeTypes = [
        "audio/aac"
        "audio/ac3"
        "audio/flac"
        "audio/mp4"
        "audio/mpeg"
        "audio/ogg"
        "audio/vnd.wave"
        "audio/webm"
        "audio/x-matroska"
        "audio/x-mpegurl"
        "video/mp2t"
        "video/mp4"
        "video/mpeg"
        "video/ogg"
        "video/quicktime"
        "video/vnd.avi"
        "video/webm"
        "video/x-matroska"
        "video/x-ms-wmv"
      ];
    in
    {
      home.packages = with pkgs; [
        ffmpeg-full
        openh264
        haruna
      ];
      xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "org.kde.haruna.desktop");
    };

  flake.homeModules.images =
    { pkgs, ... }:
    let
      inherit (lib.trivial) const;
      inherit (lib.attrsets) genAttrs;
      mimeTypes = [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
      ];
    in
    {
      home.packages = with pkgs; [
        eog
        krita
      ];
      xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "org.gnome.eog.desktop");
    };

  flake.homeModules.pdf =
    { pkgs, ... }:
    let
      inherit (lib.trivial) const;
      inherit (lib.attrsets) genAttrs;
      mimeTypes = [
        "application/pdf"
      ];
    in
    {
      home.packages = with pkgs; [
        evince
      ];
      xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "org.gnome.Evince.desktop");
    };
}
