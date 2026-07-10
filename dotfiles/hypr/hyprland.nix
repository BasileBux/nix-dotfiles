{
  pkgs,
  inputs,
  config,
  settings,
  ...
}:

let
  input-hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  repoRoot = settings.configPath;
  cfgDir = "${repoRoot}/dotfiles/hypr";

  hostOrDefault = file:
    let
      hostFile = "${repoRoot}/hosts/${settings.machine}/hypr/${file}";
      defaultFile = "${cfgDir}/${file}";
    in
    if (settings ? machine) && builtins.pathExists hostFile then
      config.lib.file.mkOutOfStoreSymlink hostFile
    else
      config.lib.file.mkOutOfStoreSymlink defaultFile;
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
  ];

  # export HYPRLAND_STUBS="$(dirname $(dirname $(readlink -f $(which hyprland))))/share/hypr/stubs"
  home.sessionVariables = {
    HYPRLAND_STUBS = "${input-hyprland}/share/hypr/stubs";
  };

  xdg.configFile."hypr/hyprland.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgDir}/hyprland.lua";

  xdg.configFile."hypr/input.lua".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgDir}/input.lua";

  xdg.configFile."hypr/config.lua".source = hostOrDefault "config.lua";

  xdg.configFile."hypr/host.lua".source = hostOrDefault "host.lua";

  xdg.configFile."hypr/lua".source =
    config.lib.file.mkOutOfStoreSymlink "${cfgDir}/lua";

  home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
      ${pkgs.hyprland}/bin/hyprctl reload
    fi
  '';
}
