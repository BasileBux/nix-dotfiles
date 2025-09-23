{ lib, config, pkgs, inputs, settings, secrets, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      edit = "sudo -e";
      config = "cd ${settings.configPath} && nvim configuration.nix";
      rebuild =
        "sudo nixos-rebuild switch --flake /home/${settings.username}/nixos#default --impure && sh ${settings.configPath}/scripts/post-rebuild.sh";
      ai = ''
        nvim -c CodeCompanionChat -c "wincmd h" -c "q"
      '';
      gss = "git status";
      nvimconfig = "cd $HOME/.config/nvim && nvim init.lua";
      qsconfig =
        "cd ${settings.configPath}/dotfiles/quickshell && nvim shell.qml";
      up = "sudo nix flake update && rebuild --upgrade";

      # VPN
      vpnstart = "sudo systemctl start openvpn-hs_ch";
      vpnstop = "sudo systemctl stop openvpn-hs_ch";
      vpnstatus = "systemctl status openvpn-hs_ch";

      playground = "/home/${settings.username}/playground-cli/playground";
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
    XAI_API_KEY = secrets.keys.xaiApiKey or "";
    GITHUB_TOKEN = secrets.github-token or "";
  };
}
