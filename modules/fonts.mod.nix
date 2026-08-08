{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.fonts;
  flake.nixosModules.fonts = { pkgs, ... }: {
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
        builtins.removeAttrs (pkgs.callPackage ../dotfiles/fonts { }) [
          "override"
          "overrideDerivation"
        ]
      );
  };
}
