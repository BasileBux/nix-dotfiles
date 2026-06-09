{
  pkgs,
  inputs,
  config,
  settings,
  ...
}:

let
  input-hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
in
{
  # Dependencies for the Hyprland setup
  home.packages = with pkgs; [
    bibata-cursors # Bibata-Modern-Classic
    # openzone-cursors # OpenZone-Black
    # hackneyed # Hackneyed
    # apple-cursor # macOS
    # posy-cursors # Posy_Cursor
    # whitesur-cursors # WhiteSur-cursors
    # quintom-cursor-theme # Quintom_snow

    hyprcursor
    playerctl
    grim
    slurp
    brightnessctl
    hyprpolkitagent
  ];

  # export HYPRLAND_STUBS="$(dirname $(dirname $(readlink -f $(which hyprland))))/share/hypr/stubs"
  home.sessionVariables = {
    HYPRLAND_STUBS = "${input-hyprland}/share/hypr/stubs";
  };

  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
  xdg.configFile."hypr/input.lua".source = ./input.lua;

  xdg.configFile."hypr/config.lua".source =
    let
      hostConfig = ../../hosts + "/${settings.machine}/config.lua";
    in
    if (settings ? machine) && builtins.pathExists hostConfig then hostConfig else ./config.lua;

  xdg.configFile."hypr/lua" = {
    source = ./lua;
    recursive = true;
  };

  home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
      ${pkgs.hyprland}/bin/hyprctl reload
    fi
  '';
}
