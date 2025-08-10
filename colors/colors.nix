{ settings, ... }:
let colorTheme = "megalinee";
in {
  theme = {
    terminal =
      import "${settings.configPath}/colors/${colorTheme}/ghostty.nix";
  };
}
