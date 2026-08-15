{
  pkgs,
  lib ? pkgs.lib,
}:

let
  mkFont =
    {
      name,
      src,
    }:
    pkgs.stdenv.mkDerivation {
      pname = name;
      version = "1.0";
      src = src;
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp $src/*.ttf $out/share/fonts/truetype/
      '';
      meta.license = lib.licenses.unfree;
    };
in
{
  iosevka-custom = mkFont {
    name = "iosevka-custom";
    src = ./IosevkaCustom;
  };
}
