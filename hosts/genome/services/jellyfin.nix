{
  services.jellyfin.enable = true;

  systemd.tmpfiles.rules = [
    "d /media/jellyfin 2775 basileb users -"
  ];
}
