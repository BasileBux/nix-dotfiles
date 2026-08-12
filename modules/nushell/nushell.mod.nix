{ ... }:
let
  nushellOptionModule = { lib, ... }: {
    options.my.nushell = lib.mkOption {
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
          extraConfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
            description = "Raw nushell code sourced at the end of config.nu";
          };
        };
      };
      default = { };
      description = "Nushell module settings";
    };
  };

  nushellNixosModule = { pkgs, lib, ... }: {
    users.defaultUserShell = lib.mkDefault pkgs.nushell;
    environment.shells = [ pkgs.nushell ];
  };

  nushellHomeModule =
    {
      config,
      osConfig,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib.meta) getExe;
      inherit (lib.strings) concatLines;

      resolvedEnvNu = import ./env.nix {
        inherit
          config
          osConfig
          pkgs
          lib
          ;
      };

      secretsNu = import ./secrets.nix { inherit osConfig; };

      cfg = osConfig.my.nushell;

      promptNu = import ./prompt.nix {
        inherit pkgs;
        accentColor = cfg.accentColor;
      };

      functionsNu = import ./functions.nix { inherit pkgs; };

      aliasContent = {
        edit = "sudo -e";
        rebuild = "nh os switch";
        gss = "git status";
        vim = "nvim";
        top = "btop";
        cp = "cp --recursive --verbose --progress";
        mv = "mv --verbose";
        rm = "rm --recursive --verbose";
        sl = "ls";
        logout = "loginctl terminate-user $env.USER";
        C = "wl-copy";
        P = "wl-paste";

        la = "ls --all";
        ll = "ls --long";
        lla = "ls --long --all";
        l = "ls --all";

        fg = "job unfreeze";
        jl = "job list";
      }
      // cfg.extraShellAliases;
    in
    {
      home.packages = [
        pkgs.nushell
        pkgs.carapace
        pkgs.direnv
      ];

      xdg.configFile."nushell/env.nu".source = resolvedEnvNu;

      xdg.configFile."nushell/settings.nu".text = /* nu */ ''
        $env.config = $env.config | merge deep {
          history: {
            file_format: "sqlite"
            max_size: 1000000
          }
          show_banner: false
          edit_mode: "vi"
          cursor_shape: {
            emacs: "line"
            vi_insert: "line"
            vi_normal: "block"
          }
          completions: {
            algorithm: "substring"
          }
          use_kitty_protocol: true
          shell_integration: {
            osc9_9: false
          }
          highlight_resolved_externals: true
          table: {
            mode: "rounded"
            header_on_separator: true
            footer_inheritance: true
            missing_value_symbol: $"(ansi magenta_bold)nope(ansi reset)"
          }
        }
      '';

      xdg.configFile."nushell/aliases.nu".text = concatLines (
        lib.mapAttrsToList (name: body: "alias ${name} = ${body}") aliasContent
      );

      xdg.configFile."nushell/extra-config.nu".text = cfg.extraConfig;

      xdg.configFile."nushell/secrets-env.nu".text = secretsNu;

      xdg.configFile."nushell/config.nu".text = /* nu */ ''
        # Raise fd limit early, before anything opens many files
        ulimit --file-descriptor-count hard

        source ~/.config/nushell/env.nu

        source ~/.config/nushell/settings.nu

        source ~/.config/nushell/aliases.nu

        source ~/.config/nushell/extra-config.nu

        source ~/.config/nushell/secrets-env.nu

        source ${promptNu}

        source ${functionsNu}

        source ${
          pkgs.runCommand "carapace.nu" { } /* bash */ ''
            ${getExe pkgs.carapace} _carapace nushell > $out
          ''
        }

        source ${
          pkgs.writeText "direnv-hook.nu" /* nu */ ''
            $env.config.hooks.env_change.PWD = [
              {||
                ^direnv export json | from json | default {} | load-env
              }
            ]
          ''
        }

        $env.config.keybindings ++= [
          {
            name: history_hint_complete
            modifier: control
            keycode: char_f
            mode: [emacs, vi_normal, vi_insert]
            event: { send: HistoryHintComplete }
          }
        ]
      '';
    };
in
{
  flake.module.nushell = {
    nixos = { lib, pkgs, ... }: {
      imports = [
        nushellOptionModule
        nushellNixosModule
      ];
    };
    home = nushellHomeModule;
  };
}
