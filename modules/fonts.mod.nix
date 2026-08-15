{ ... }: {
  flake.module.fonts = {
    nixos = { pkgs, ... }: {
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
        ++ builtins.attrValues (
          builtins.removeAttrs (pkgs.callPackage ../config/fonts { }) [
            "override"
            "overrideDerivation"
          ]
        );
    };
  };
}
