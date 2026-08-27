{
  services.jellyfin.enable = true;

  # Shared group for services managing the media library.
  users.groups.media = { };

  users.users.jellyfin.extraGroups = [ "media" ];
  users.users.basileb.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /media/jellyfin 2775 basileb media -"
  ];
}
