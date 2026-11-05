{ ... }: {
  flake.module.vscode = {
    home =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        config = {
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
              ];
          };

          xdg.configFile."Code/User/settings.json".source = ../config/vscode/settings.json;
          xdg.configFile."Code/User/keybindings.json".source = ../config/vscode/keybindings.json;
        };
      };
  };
}
