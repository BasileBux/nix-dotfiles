{ pkgs }:

{ pname, version, url, hash
, extraBwrapArgs ? [ "--bind-try /etc/nixos/ /etc/nixos/" ]
, dieWithParent ? false, extraPkgs ? pkgs:
  with pkgs; [
    unzip
    autoPatchelfHook
    asar
    (buildPackages.wrapGAppsHook3.override {
      inherit (buildPackages) makeWrapper;
    })
  ], desktopName ? pname, extraInstallCommands ? "" }:

let
  src = pkgs.fetchurl { inherit url hash; };

  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in pkgs.appimageTools.wrapType2 {
  inherit pname version src dieWithParent extraBwrapArgs extraPkgs;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${desktopName}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${desktopName}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
    ${extraInstallCommands}
  '';
}
