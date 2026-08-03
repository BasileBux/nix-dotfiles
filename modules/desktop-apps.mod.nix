{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.desktop-apps;
  flake.nixosModules.desktop-apps = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      yazi
      steam
      thunderbird
      imhex
    ];
  };
}
