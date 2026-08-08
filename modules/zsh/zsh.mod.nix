{
  self,
  ...
}:
let
  zshOptionModule = { lib, ... }: {
    options.my.zsh = lib.mkOption {
      type = lib.types.submodule {
        options = {
          accentColor = lib.mkOption {
            type = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
            default = "#fb8b1e";
            description = "Main accent color for prompts/theming, as #RRGGBB";
          };
          extraShellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "Extra shell aliases appended to the built-in set";
          };
        };
      };
      default = { };
      description = "Zsh module settings";
    };
  };
in
{
  flake.nixosModules.zsh = zshOptionModule;
  flake.nixosModules.shell = self.nixosModules.zsh;

  flake.homeModules.shell = self.homeModules.zsh;
  flake.homeModules.zsh =
    {
      config,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = osConfig.my.zsh;

      aliasContent = {
        edit = "sudo -e";
        rebuild = "nh os switch --impure";
        gss = "git status";
        vim = "nvim";
        top = "btop";
        cp = "cp --recursive --verbose";
        mv = "mv --verbose";
        rm = "rm --recursive --verbose";
        sl = "ls";
        logout = "loginctl terminate-user $USER";
        C = "wl-copy";
        P = "wl-paste";
        NULL = "/dev/null 2>&1";
      };

      aliases = aliasContent // cfg.extraShellAliases;

      themeFile = pkgs.runCommand "basileb.zsh-theme" { accentColor = cfg.accentColor; } ''
        r=$(printf '%d' 0x''${accentColor:1:2})
        g=$(printf '%d' 0x''${accentColor:3:2})
        b=$(printf '%d' 0x''${accentColor:5:2})
        sed -e "s|@accent_rgb@|$r;$g;$b|g" ${../../dotfiles/zsh/basileb.zsh-theme} > $out
      '';

      zshCustom = pkgs.runCommand "zsh-custom" { } ''
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
        shellAliases = aliases;
        initContent = "source ~/.zsh/secrets-env\n" + builtins.readFile ../../dotfiles/zsh/initContent.zsh;
        history = {
          size = 10000;
          save = 10000;
          share = false;
          path = "${config.xdg.stateHome}/zsh/history";
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
        TYPSTDIR = "${config.xdg.dataHome}/typst/packages";
      };

      home.file.".zsh/secrets-env".text = ''
        export ANTHROPIC_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/anthropic.age".path})"
        export OPENAI_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/openai.age".path})"
        export GEMINI_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/gemini.age".path})"
        export GOOGLE_GENERATIVE_AI_API_KEY="$(cat ${
          osConfig.age.secrets."modules/zsh/api-keys/google-generative-ai.age".path
        })"
        export MOONSHOT_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/moonshot.age".path})"
        export TAVILY_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/tavily.age".path})"
        export XAI_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/xai.age".path})"
        export GITHUB_TOKEN="$(cat ${osConfig.age.secrets."modules/zsh/github-token.age".path})"
        export NVIDIA_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/nvidia.age".path})"
        export DEEPSEEK_API_KEY="$(cat ${osConfig.age.secrets."modules/zsh/api-keys/deepseek.age".path})"
        export RAD_PASSPHRASE="$(cat ${osConfig.age.secrets."modules/zsh/rad-passphrase.age".path})"
      '';
    };
}
