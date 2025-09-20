{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bierner.markdown-emoji
      bierner.markdown-preview-github-styles
      ms-vscode.cmake-tools
      ms-vscode.cpptools
      ms-vscode.cpptools-extension-pack
      ms-vscode.makefile-tools
      pkief.material-icon-theme
      twxs.cmake
      vscodevim.vim
      aaron-bond.better-comments
      # NyoomEngineering.oxocarbon-vscode
      # miguelsolorio.fluent-icons
      # janisdd.vscode-edit-csv
      # tobias-z.vscode-harpoon
      # BasileBuxtorf.good-harpoon
    ];
  };

  home.activation.vscode-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p ~/.config/Code/User
    $DRY_RUN_CMD cp -f ${
      ./vscode/settings.json
    } ~/.config/Code/User/settings.json
    $DRY_RUN_CMD cp -f ${
      ./vscode/keybindings.json
    } ~/.config/Code/User/keybindings.json
    $DRY_RUN_CMD chmod +w ~/.config/Code/User/settings.json ~/.config/Code/User/keybindings.json
  '';
}
