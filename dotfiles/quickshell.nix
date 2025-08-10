{ config, lib, pkgs, settings, ... }:

let
  quickshellSrc = builtins.path {
    path = "${settings.configPath}/dotfiles/quickshell";
    name = "quickshell-src";
  };

  # Removes two last lines of Globals.qml, adds a new line with the machine property
  # and appends it to the end of the file.
  # This is necessary to make the machine property available in the QML context
  # while keeping the original config runnable without nix or home-manager.
  quickshellConfigured = pkgs.runCommand "quickshell-config" { } ''
    set -euo pipefail

    mkdir -p "$out"
    cp -r ${quickshellSrc}/. "$out/"

    file="$out/Globals.qml"
    if [ ! -f "$file" ]; then
      echo "Globals.qml not found at: $file" >&2
      exit 1
    fi

    tmp="$out/.Globals.qml.tmp"
    head -n -2 "$file" > "$tmp"
    printf '    readonly property string machine: "${settings.machine}"\n}\n' >> "$tmp"
    mv "$tmp" "$file"
  '';
in {
  xdg.configFile."quickshell".source = quickshellConfigured;
}
