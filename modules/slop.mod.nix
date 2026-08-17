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

    # pi coding agent user config, deployed to $PI_CODING_AGENT_DIR
    # (~/.config/pi, see modules/xdg.mod.nix). Source files live in
    # config/pi/ next to the other native-language configs.
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
          "pi/AGENTS.md".source = ../config/pi/AGENTS.md;
          "pi/themes".source = ../config/pi/themes;
          "pi/extensions".source = ../config/pi/extensions;
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
      {

        options.my.t3Host = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "The host address to serve t3code on";
        };

        config = {
          environment.systemPackages = [
            pkgs.t3code
          ];

          # SHELL is forced to bash because t3code's PATH hydration runs `printenv
          # PATH || true` through a login shell, which nushell rejects at parse time.
          systemd.services.t3 = {
            description = "T3 Code server";
            wantedBy = [ "multi-user.target" ];
            wants = [ "network-online.target" ];
            after = [
              "network-online.target"
              "tailscaled.service"
            ];
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
              ExecStart = "${pkgs.t3code}/bin/t3 serve --host ${config.my.t3Host}";
              Restart = "on-failure";
              RestartSec = 10;
            };
          };
        };
      };
  };
}
