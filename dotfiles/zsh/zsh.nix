{ config, pkgs, inputs, settings, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      edit = "sudo -e";
      rebuild =
        "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure";
      ai = ''
        nvim -c CodeCompanionChat -c "wincmd h" -c "q"
      '';
      gss = "git status";
    };

    history = {
      size = 10000;
      save = 10000;
      share = false;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ ];
      custom = "${settings.configPath}/dotfiles/zsh";
      theme = "basileb";
    };
  };
}
