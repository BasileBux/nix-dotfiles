{ lib, config, pkgs, inputs, settings, colors, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions;
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
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
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
          version = "0.11.7";
          sha256 = "sha256-8buRNSxfKmf9+MZDvFOOyrbXtbIC7GbHPRCBVnAHXrA=";
        }
        {
          name = "good-harpoon";
          publisher = "BasileBuxtorf";
          version = "0.0.1";
          sha256 = "sha256-e68jaeVUJLgb8gfXRgRaPhcInzyIpWAeKzvuQfLGb9s=";
        }
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
