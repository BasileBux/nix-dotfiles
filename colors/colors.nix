{ settings, ... }:
let colorTheme = "megalinee";
in {
  theme = {
    terminal =
      import "${settings.configPath}/colors/${colorTheme}/ghostty.nix";
    waybar =
      import "${settings.configPath}/colors/${colorTheme}/waybar.nix";
    wofi =
      import "${settings.configPath}/colors/${colorTheme}/wofi.nix";
    wlogout =
      import "${settings.configPath}/colors/${colorTheme}/wlogout.nix";
  };
}
