{ lib, config, pkgs, inputs, settings, ... }:
let
  secretsPath = "${settings.configPath}/secrets.nix";
  secretsExists = builtins.pathExists secretsPath;
  secrets = if secretsExists then import secretsPath else {};
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      edit = "sudo -e";
      config = ''
        cd ${settings.configPath} && nvim -c "e configuration.nix" -c "tabnew" -c "e flake.nix" -c "tabnew" -c "e home.nix"
      '';
      rebuild =
        "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure && sh ${settings.configPath}/scripts/post-rebuild.sh";
      ai = ''
        nvim -c CodeCompanionChat -c "wincmd h" -c "q"
      '';
      gss = "git status";
      nvimconfig = "cd $HOME/.config/nvim && nvim -c 'e init.lua' -c 'tabnew' -c 'e lua/lazy-plugins.lua'";
      qsconfig = "cd ${settings.configPath}/dotfiles/quickshell && nvim -c 'e shell.qml' -c 'tabnew' -c 'e Globals.qml'";
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

  home.sessionVariables = {
      ANTHROPIC_API_KEY = secrets.keys.anthropicApiKey or "";
      OPENAI_API_KEY = secrets.keys.openaiApiKey or "";
      GEMINI_API_KEY = secrets.keys.geminiApiKey or "";
      MOONSHOT_API_KEY = secrets.keys.moonshotApiKey or "";
      TAVILY_API_KEY = secrets.keys.tavilyApiKey or "";
    };
}
