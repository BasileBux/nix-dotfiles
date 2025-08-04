{ stdenv, fetchurl }:
{
   sddm-custom-theme = stdenv.mkDerivation rec {
      pname = "sddm-custom-theme";
      version = "1.0";
      dontBuild = true;
      src = ./custom; # Path to your theme directory
      installPhase = ''
        mkdir -p $out/share/sddm/themes
        cp -aR $src $out/share/sddm/themes/custom
      '';
   };
}
