{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  pname = "qbittorrent-scripts";
  version = "1";

  src = ./.;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 ./qbittorrent-init.sh $out/bin/qbittorrent-init.sh
    install -m755 ./torrent-done.sh $out/bin/torrent-done.sh
    runHook postInstall
  '';

  meta = with lib; {
    description = "qBittorrent automation scripts (init + torrent-done hook)";
    homepage = "https://github.com/BasileBux/nixos";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}
