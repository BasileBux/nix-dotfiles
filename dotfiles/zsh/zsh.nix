{
  lib,
  config,
  pkgs,
  inputs,
  settings,
  secrets,
  ...
}:
let
  alias = import ./alias.nix {
    inherit
      lib
      config
      pkgs
      inputs
      settings
      ;
  };

  themeFile = pkgs.runCommand "basileb.zsh-theme" {
    accentColor = settings.accentColor;
  } ''
    r=$(printf '%d' 0x''${accentColor:1:2})
    g=$(printf '%d' 0x''${accentColor:3:2})
    b=$(printf '%d' 0x''${accentColor:5:2})

    sed -e "s|@accent_rgb@|$r;$g;$b|g" ${./basileb.zsh-theme} > $out
  '';

  zshCustom = pkgs.runCommand "zsh-custom" {} ''
    mkdir -p $out
    cp ${themeFile} $out/basileb.zsh-theme
  '';
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = alias;

    initContent = builtins.readFile ./initContent.zsh;

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
      custom = "${zshCustom}";
      theme = "basileb";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    TYPSTDIR = "$HOME/.local/share/typst/packages";
    GIT_EXTERNAL_DIFF = "difft";

    ANTHROPIC_API_KEY = secrets.keys.anthropicApiKey or "";
    OPENAI_API_KEY = secrets.keys.openaiApiKey or "";
    GEMINI_API_KEY = secrets.keys.geminiApiKey or "";
    GOOGLE_GENERATIVE_AI_API_KEY = secrets.keys.googleGenerativeAiApiKey or "";
    MOONSHOT_API_KEY = secrets.keys.moonshotApiKey or "";
    TAVILY_API_KEY = secrets.keys.tavilyApiKey or "";
    XAI_API_KEY = secrets.keys.xaiApiKey or "";
    GITHUB_TOKEN = secrets.github-token or "";
    NVIDIA_API_KEY = secrets.keys.nvidiaApiKey or "";
    RAD_PASSPHRASE = secrets.rad-passphrase or "";
  };
}
