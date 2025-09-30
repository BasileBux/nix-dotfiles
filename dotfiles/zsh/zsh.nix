{ lib, config, pkgs, inputs, settings, secrets, ... }:
let
  alias =
    import ./alias.nix { inherit lib config pkgs inputs settings secrets; };
in {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = alias;

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
    XAI_API_KEY = secrets.keys.xaiApiKey or "";
    GITHUB_TOKEN = secrets.github-token or "";
  };
}
