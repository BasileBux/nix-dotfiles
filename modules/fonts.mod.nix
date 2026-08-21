{ lib, ... }: {
  flake.module.fonts = {
    nixos =
      {
        pkgs,
        config,
        ...
      }:
      let
        # The font catalog (../packages/fonts): auto-discovers one entry per family
        # directory. Regular fonts are derivations; encrypted (paid) fonts are metadata
        # records (`__encryptedFont`).
        catalog = pkgs.callPackage ../packages/fonts { };
        allFonts = builtins.attrValues (
          builtins.removeAttrs catalog [
            "override"
            "overrideDerivation"
          ]
        );
        regular = builtins.filter (f: !(f ? __encryptedFont)) allFonts;
        encrypted = builtins.filter (f: f ? __encryptedFont) allFonts;
      in
      {
        fonts.packages =
          with pkgs;
          [
            nerd-fonts.jetbrains-mono
            nerd-fonts.geist-mono
            nerd-fonts.go-mono
            nerd-fonts.gohufont
            googlesans-code
            inter
          ]
          ++ regular;

        assertions = lib.mkIf (encrypted != [ ]) [
          {
            assertion = config.my.secrets.enabled;
            message = ''
              The fonts module installs encrypted fonts (${
                lib.concatStringsSep ", " (map (f: f.name) encrypted)
              }), which are decrypted by agenix at activation, but this host
              has no age identity (my.secrets.enabled is false).
              Set ageIdentityPaths in hosts/<host>/<host>.mod.nix, e.g.
              ageIdentityPaths = [ "/home/<user>/.ssh/<host>" ];
            '';
          }
        ];
      };

    home =
      { pkgs, lib, ... }:
      let
        catalog = pkgs.callPackage ../packages/fonts { };
        encrypted = builtins.filter (f: f ? __encryptedFont) (
          builtins.attrValues (
            builtins.removeAttrs catalog [
              "override"
              "overrideDerivation"
            ]
          )
        );
      in
      {
        home.activation = lib.listToAttrs (
          map (f: {
            name = "fonts-${f.name}";
            value = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              secret=/run/agenix/${f.secretName}
              target="$HOME/.local/share/fonts/${f.name}"
              if [[ -f "$secret" ]]; then
                mkdir -p "$target"
                ${pkgs.gzip}/bin/zcat "$secret" | ${pkgs.gnutar}/bin/tar -x -C "$target" --overwrite
                ${pkgs.fontconfig}/bin/fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
              fi
            '';
          }) encrypted
        );
      };
  };
}
