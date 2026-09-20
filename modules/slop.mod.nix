{ inputs, ... }: {
  flake.module.slop = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        pi-coding-agent
        opencode
        inputs.qq.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };

    home =
      { pkgs, lib, ... }:
      let
        piSettings = builtins.fromJSON (builtins.readFile ../config/pi/settings.json);
        # settings.json is written by pi itself (changelog version tracking,
        # `pi install`, /settings), so it is deployed as a writable file rather
        # than a read-only store symlink. The version field is derived from the
        # pinned package instead of being hardcoded in the repo.
        inherit (lib.attrsets) genAttrs;
        inherit (lib.trivial) const;

        piSettings' = piSettings // {
          lastChangelogVersion = pkgs.pi-coding-agent.version;
        };

        # READ-ONLY VCS COMMANDS
        vcsCommands =
          [
            "jj bookmark list*"
            "jj config get*"
            "jj config list*"
            "jj config path*"
            "jj diff*"
            "jj evolog*"
            "jj file annotate*"
            "jj file list*"
            "jj file search*"
            "jj file show*"
            "jj git colocation status*"
            "jj git remote list*"
            "jj git root*"
            "jj help*"
            "jj interdiff*"
            "jj log*"
            "jj op diff*"
            "jj op log*"
            "jj op show*"
            "jj operation diff*"
            "jj operation log*"
            "jj operation show*"
            "jj resolve --list"
            "jj root*"
            "jj show*"
            "jj sparse list*"
            "jj st*"
            "jj status*"
            "jj tag list*"
            "jj util completion*"
            "jj util config-schema*"
            "jj util markdown-help*"
            "jj version*"
            "jj workspace list*"
            "jj workspace root*"

            # git is the fallback for non-jj repos, so allow reading it too.
            "git status*"
            "git log*"
            "git diff*"
            "git show*"
            "git blame*"
            "git shortlog*"
            "git rev-parse*"
            "git describe*"
            "git ls-files*"
            "git ls-remote*"
            "git check-ignore*"
            "git remote -v"
            "git remote get-url*"
            "git config --get*"
            "git branch --show-current"
            "git branch --list*"
            "git branch -a"
            "git branch -v"
            "git worktree list*"
            "git help*"
            "git version*"
          ];

        opencodeConfig = {
          "$schema" = "https://opencode.ai/config.json";

          autoupdate = false;

          permission = {
            "*" = "ask";

            edit = "allow";
            read = "allow";
            grep = "allow";
            glob = "allow";
            list = "allow";
            lsp = "allow";
            task = "allow";
            todoread = "allow";
            todowrite = "allow";
            webfetch = "allow";
            websearch = "allow";

            # EDIT ANYWHERE
            external_directory."/**" = "allow";

            bash = genAttrs vcsCommands (const "allow");
          };
        };
      in
      {
        xdg.configFile = {
          "pi/settings.json".text = (builtins.toJSON piSettings') + "\n";
          "pi/keybindings.json".source = ../config/pi/keybindings.json;
          "pi/models.json".source = ../config/pi/models.json;
          "pi/web-search.json".source = ../config/pi/web-search.json;
          "pi/AGENTS.md".source = ../config/slop/AGENTS.md;
          "opencode/AGENTS.md".source = ../config/slop/AGENTS.md;

          # opencode writes model/provider selections back into this file (the
          # ollama provider above was originally created that way), so it is
          # deployed as a writable file rather than a read-only store symlink.
          "opencode/opencode.json".text = (builtins.toJSON opencodeConfig) + "\n";
          "pi/themes".source = ../config/pi/themes;
          "pi/extensions".source = ../config/pi/extensions;
          "pi/skills".source = ../config/pi/skills;
        };

        home.sessionVariables = {
          PI_SKIP_VERSION_CHECK = "1";
          OPENCODE_ENABLE_EXA = "1";
        };
      };
  };

  flake.module.t3 = {
    nixos =
      {
        pkgs,
        config,
        lib,
        ...
      }:
      let
        apiKeySecrets = lib.filter (s: lib.hasPrefix "modules/secrets/env/api-keys/" s.path) (
          import ./secrets/env-secrets.nix { inherit lib; }
        );
        cfg = config.my.services.t3;
      in
      {

        options.my.services.t3 = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable T3 Code server (served on the tailnet)";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 3773;
            description = "Loopback port for the HTTP/WebSocket server (t3code default: 3773)";
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = config.my.secrets.enabled;
              message = ''
                The t3 module needs an age identity to decrypt the API key
                secrets (modules/secrets/env/api-keys/*.age), but no identity
                is configured (my.secrets.enabled is false).
                Set ageIdentityPaths in hosts/<host>/<host>.mod.nix, e.g.
                ageIdentityPaths = [ "/home/<user>/.ssh/<host>" ];
              '';
            }
          ];

          environment.systemPackages = [
            pkgs.t3code
          ];

          systemd.services.t3 = {
            description = "T3 Code server";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig = {
              Type = "exec";
              User = config.my.settings.username;
              Environment = [
                "HOME=/home/${config.my.settings.username}"
                "SHELL=/run/current-system/sw/bin/bash"
                "PATH=/run/current-system/sw/bin"
                "CODEX_HOME=/home/${config.my.settings.username}/.config/codex"
                "T3CODE_HOME=/home/${config.my.settings.username}/.config/t3"
              ];
              RuntimeDirectory = "t3";
              RuntimeDirectoryMode = "0700";
              EnvironmentFile = "-/run/t3/env";
              ExecStartPre = pkgs.writeShellScript "t3-secrets-env" ''
                set -euo pipefail
                umask 077
                envFile=/run/t3/env
                : > "$envFile"
                ${lib.concatStringsSep "\n" (
                  map (s: ''
                    printf '%s=%s\n' '${s.name}' "$(cat '${
                      config.age.secrets.${s.path}.path
                    }' | tr -d '\n')" >> "$envFile"
                  '') apiKeySecrets
                )}
              '';
              ExecStart = "${pkgs.t3code}/bin/t3 serve --host 127.0.0.1 --port ${toString cfg.port}";
              Restart = "on-failure";
              RestartSec = 10;
            };
          };

          my.services.ports.t3 = cfg.port;
          my.tailscale.serve.t3.port = cfg.port;
        };
      };
  };
}
