{
  lib,
  pkgs,
  ...
}:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions =
      with pkgs.vscode-extensions;
      [
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
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "ayu";
          publisher = "teabyii";
          version = "1.1.12";
          sha256 = "sha256-pwLvik3GRMLyr6GeTmZh1MrkgH1MgbyoembNmQxg4I0=";
        }
        {
          name = "oxocarbon-vscode";
          publisher = "NyoomEngineering";
          version = "1.2.0";
          sha256 = "sha256-ubpnirC/MOe76gxmgE8vubcCwinkAeMXEzK0fvixk1U=";
        }
        {
          name = "fluent-icons";
          publisher = "miguelsolorio";
          version = "0.0.19";
          sha256 = "sha256-OfPSh0SapT+YOfi0cz3ep8hEhgCTHpjs1FfmgAyjN58=";
        }
        {
          name = "vscode-edit-csv";
          publisher = "janisdd";
          version = "0.11.9";
          sha256 = "sha256-hbu/r3mBtb9nDZcP8kY4fBJ5ZuKwkO/kJFk1OWDIdlk=";
        }
        # Install https://marketplace.visualstudio.com/items?itemName=TaeKim.fast-fuzzy-finder
        # which doesn't work with this home-manager module
      ];
  };

  home.activation.vscode-config = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p ~/.config/Code/User
    $DRY_RUN_CMD cp -f ${./vscode/settings.json} ~/.config/Code/User/settings.json
    $DRY_RUN_CMD cp -f ${./vscode/keybindings.json} ~/.config/Code/User/keybindings.json
    $DRY_RUN_CMD chmod +w ~/.config/Code/User/settings.json ~/.config/Code/User/keybindings.json
  '';
}
