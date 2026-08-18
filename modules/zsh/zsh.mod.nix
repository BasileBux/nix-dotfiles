{ ... }:
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
    config = {
      programs.zsh.enable = true;
    };
  };
in
{
  flake.module.zsh = {
    nixos = zshOptionModule;
    home =
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
          rebuild = "nh os switch";
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
          sed -e "s|@accent_rgb@|$r;$g;$b|g" ${./basileb.zsh-theme} > $out
        '';

        zshCustom = pkgs.runCommand "zsh-custom" { } ''
          mkdir -p $out
          cp ${themeFile} $out/basileb.zsh-theme
        '';

        envSecrets = import ../secrets/env-secrets.nix { inherit lib; };
      in
      {
        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;
          syntaxHighlighting.enable = true;
          shellAliases = aliases;
          initContent = "source ~/.config/zsh/secrets-env\n" + builtins.readFile ./initContent.zsh;
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

        xdg.configFile."zsh/secrets-env".text = lib.optionalString osConfig.my.secrets.enabled (
          builtins.concatStringsSep "\n" (
            map (
              s: "export ${s.name}=\"$(cat ${osConfig.age.secrets.${s.path}.path})\""
            ) envSecrets
          )
        );
      };
  };
}
