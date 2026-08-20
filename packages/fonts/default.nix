# Encrypted fonts are NOT derivations: they are metadata records
# (`__encryptedFont = true` with the payload file name and agenix secret name).
# The fonts module (modules/fonts.mod.nix) uses them to register an agenix
# secret and extract the decrypted payload into ~/.local/share/fonts at
# activation — so the host's SSH identity is never read by any build, and the
# paid font's plaintext never enters the nix store.
{
  pkgs,
  lib,
}:

let
  inherit (builtins)
    attrNames
    concatStringsSep
    head
    pathExists
    readDir
    ;
  inherit (lib) licenses;

  # License registry: string key → nixpkgs license. Unknown keys throw, so a
  # missing/typo'd license can never silently end up as `unfree`.
  licenseTable = {
    ofl = licenses.ofl;
    "cc-by-sa-40" = licenses.cc-by-sa-40;
    unfree = licenses.unfree;
    "unfree-redistributable" = licenses.unfreeRedistributable;
    mit = licenses.mit;
    # add more as needed
  };

  fontRoot = ./.;

  # Every subdirectory of fontRoot is one font family.
  dirs = attrNames (lib.filterAttrs (name: type: type == "directory") (readDir fontRoot));

  # A directory containing *.age files is an encrypted font — that is the
  # source of truth, so a stray payload can never be built as a regular font.
  hasAgeFiles = dir: lib.any (lib.hasSuffix ".age") (attrNames (readDir (fontRoot + "/${dir}")));

  readFontNix = dir: import (fontRoot + "/${dir}/font.nix");

  # Assemble one font's metadata with defaults.
  metadata =
    dir:
    let
      m = if pathExists (fontRoot + "/${dir}/font.nix") then readFontNix dir else { };
      encrypted = hasAgeFiles dir || (m.encrypted or false);
      name = m.name or dir;
      version = m.version or "0-unstable";
      licenseKey = m.license or (if encrypted then "unfree" else null);
      license =
        if licenseKey == null then
          throw ''
            packages/fonts: '${dir}' has no license.
            Add font.nix, e.g. { name = "${dir}"; license = "ofl"; }
          ''
        else if licenseTable ? ${licenseKey} then
          licenseTable.${licenseKey}
        else
          throw "packages/fonts: '${dir}' has unknown license '${licenseKey}' (known: ${concatStringsSep ", " (attrNames licenseTable)})";
    in
    {
      inherit
        dir
        encrypted
        name
        version
        license
        ;
      homepage = m.homepage or null;
      description = m.description or null;
    };

  mkRegular =
    m:
    pkgs.stdenv.mkDerivation {
      pname = m.name;
      version = m.version;
      src = fontRoot + "/${m.dir}";

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/fonts/truetype $out/share/fonts/opentype $out/share/licenses/$pname
        cp $src/*.ttf $out/share/fonts/truetype/ 2>/dev/null || true
        cp $src/*.otf $out/share/fonts/opentype/ 2>/dev/null || true
        cp $src/LICENSE* $src/OFL* $src/COPYING* $src/*.md $out/share/licenses/$pname/ 2>/dev/null || true
        runHook postInstall
      '';

      meta = {
        license = m.license;
        homepage = m.homepage;
        description = m.description or "Font: ${m.name}";
      };
    };

  mkEncrypted =
    m:
    let
      payload = head (
        builtins.filter (lib.hasSuffix ".age") (attrNames (readDir (fontRoot + "/${m.dir}")))
      );
    in
    {
      __encryptedFont = true;
      inherit (m)
        name
        dir
        version
        license
        homepage
        description
        ;
      inherit payload;
      secretName = "packages/fonts/${m.dir}/${payload}";
    };

  fonts = map metadata dirs;

  names = map (m: m.name) fonts;
in
if names != lib.unique names then
  throw "packages/fonts: duplicate font names: ${concatStringsSep ", " names}"
else
  lib.listToAttrs (
    map (m: {
      name = m.name;
      value = if m.encrypted then mkEncrypted m else mkRegular m;
    }) fonts
  )
