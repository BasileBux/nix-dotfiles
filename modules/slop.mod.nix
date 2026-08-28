{ inputs, ... }: {
  flake.module.slop = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          optmem = inputs.self.packages.${final.stdenv.hostPlatform.system}.optmem;
        })
      ];
      environment.systemPackages = with pkgs; [
        pi-coding-agent
        opencode
        optmem
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
        piSettings' = piSettings // {
          lastChangelogVersion = pkgs.pi-coding-agent.version;
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
          "pi/themes".source = ../config/pi/themes;
          "pi/extensions".source = ../config/pi/extensions;
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
          enable = lib.mkEnableOption "T3 Code server (served on the tailnet)";

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

  flake.module.paseo = {
    nixos =
      {
        inputs,
        pkgs,
        config,
        lib,
        ...
      }:
      let
        apiKeySecrets = lib.filter (s: lib.hasPrefix "modules/secrets/env/api-keys/" s.path) (
          import ./secrets/env-secrets.nix { inherit lib; }
        );
        paseo = inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.default;
        cfg = config.my.services.paseo;
      in
      {

        options.my.services.paseo = {
          enable = lib.mkEnableOption "Paseo code agent server (served on the tailnet)";

          port = lib.mkOption {
            type = lib.types.port;
            default = 6767;
            description = "Loopback port for the HTTP/WebSocket server";
          };
        };

        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = config.my.secrets.enabled;
              message = ''
                The paseo module needs an age identity to decrypt the API key
                secrets (modules/secrets/env/api-keys/*.age), but no identity
                is configured (my.secrets.enabled is false).
                Set ageIdentityPaths in hosts/<host>/<host>.mod.nix, e.g.
                ageIdentityPaths = [ "/home/<user>/.ssh/<host>" ];
              '';
            }
          ];

          environment.systemPackages = [
            paseo
          ];

          systemd.services.paseo = {
            description = "Paseo Code server";
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
                "PASEO_HOME=/home/${config.my.settings.username}/.config/paseo"
              ];
              RuntimeDirectory = "paseo";
              RuntimeDirectoryMode = "0700";
              EnvironmentFile = "-/run/paseo/env";
              ExecStartPre = pkgs.writeShellScript "paseo-secrets-env" ''
                set -euo pipefail
                umask 077
                envFile=/run/paseo/env
                : > "$envFile"
                ${lib.concatStringsSep "\n" (
                  map (s: ''
                    printf '%s=%s\n' '${s.name}' "$(cat '${
                      config.age.secrets.${s.path}.path
                    }' | tr -d '\n')" >> "$envFile"
                  '') apiKeySecrets
                )}
              '';
              ExecStart = "${paseo}/bin/paseo daemon start --listen 127.0.0.1:${toString cfg.port} --web-ui --no-relay --foreground";
              Restart = "on-failure";
              RestartSec = 10;
            };
          };

          my.services.ports.paseo = cfg.port;
          my.tailscale.serve.paseo.port = cfg.port;
        };
      };
  };
}
