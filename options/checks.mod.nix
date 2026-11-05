{ self, lib, ... }: {
  perSystem =
    { pkgs, system, ... }:
    let
      hosts = lib.filterAttrs (
        _: host: host.pkgs.stdenv.hostPlatform.system == system
      ) self.nixosConfigurations;
      pass =
        name: ok:
        assert lib.assertMsg ok "Regression failed: ${name}";
        pkgs.runCommand name { } "touch $out";
      simon = self.nixosConfigurations.simon;
      kamina = self.nixosConfigurations.kamina;
      changed = simon.extendModules {
        modules = [
          ({ lib, ... }: {
            my.settings.gitName = lib.mkForce "Settings regression";
          })
        ];
      };
      disabled = kamina.extendModules { modules = [ { my.syncthing.enable = false; } ]; };
      withoutSecret = self.nixosConfigurations.genome.extendModules {
        modules = [ ({ lib, ... }: { my.services.linkwarden.secretFiles.nextauth = lib.mkForce null; }) ];
      };
      disabledWeb = self.nixosConfigurations.genome.extendModules {
        modules = [ { my.services.upsnap.enable = false; } ];
      };
      defaults =
        (import ../lib/mkHost.nix {
          inputs = self.inputs // {
            inherit self;
          };
          inherit lib;
        })
          {
            settings = {
              username = "basileb";
              hostname = "simon";
              stateVersion = "25.05";
            };
            modules = [ self.flakeModules.personal ];
          };
      keyless = simon.extendModules {
        modules = [
          ({ lib, ... }: {
            age.identityPaths = lib.mkForce [ ];
            age.secrets = lib.mkForce { };
            my.syncthing.enable = false;
          })
        ];
      };
      emptyTailnet = self.nixosConfigurations.genome.extendModules {
        modules = [
          ({ lib, ... }: {
            my.tailscale.routes = lib.mkForce [ ];
            my.tailscale.serve = lib.mkForce { };
          })
        ];
      };
      quoted = simon.extendModules {
        modules = [
          {
            my.hyprland.startup = [ ''notify-send "quoted" 'single' \\backslash'' ];
            home-manager.users.basileb.home.sessionVariables.CONFIG_REGRESSION =
              ''spaces "quotes" 'single' \\backslash $literal'';
          }
        ];
      };
      hm = quoted.config.home-manager.users.basileb;
    in
    {
      formatter = pkgs.nixfmt-tree;
      checks =
        lib.mapAttrs' (
          name: host:
          lib.nameValuePair "host-${name}" (
            builtins.seq host.config.system.build.toplevel.drvPath (pass "host-${name}-evaluation" true)
          )
        ) hosts
        // {
          settings = pass "settings-propagation" (
            changed.config.home-manager.users.basileb.programs.git.settings.user.name == "Settings regression"
          );
          settings-defaults = pass "settings-defaults" (
            defaults.config.home-manager.users.basileb.programs.git.settings.user.name
            == defaults.config.my.settings.gitName
            && defaults.config.home-manager.users.basileb.home.stateVersion == "25.05"
          );
          required-secret = pass "required-secret-assertion" (
            lib.any (
              a: !a.assertion && lib.hasInfix "secretFiles.nextauth is required" a.message
            ) withoutSecret.config.assertions
          );
          disabled-service = pass "disabled-service-cleanup" (
            !(disabledWeb.config.systemd.services ? upsnap)
            && !(disabledWeb.config.my.tailscale.serve ? upsnap)
            && !(disabledWeb.config.my.services.ports ? upsnap)
          );
          snapshot = pass "snapshot-gating" (
            !(kamina.config.systemd.timers ? jj-snapshot) && !(disabled.config.systemd.services ? syncthing)
          );
          keyless = pass "optional-keyless-consumers" (
            keyless.config.my.secrets.requested == [ ]
            && keyless.config.age.secrets == { }
            && !(keyless.config.home-manager.users.basileb.home.activation ? fonts-tx-02)
          );
          tailnet-empty = pass "tailnet-empty-state" (
            emptyTailnet.config.systemd.services ? tailscale-serve
            && emptyTailnet.config.systemd.services ? tailscale-routes
            && emptyTailnet.config.systemd.services.tailscale-serve.serviceConfig ? ExecStop
            && emptyTailnet.config.systemd.services.tailscale-routes.serviceConfig ? ExecStop
          );
          module-deduplication = pass "module-deduplication" (
            builtins.length simon.config.age.identityPaths == 1
            &&
              builtins.length simon.config.my.secrets.requested
              == builtins.length (lib.unique simon.config.my.secrets.requested)
          );
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          generated-config =
            pkgs.runCommand "generated-config-syntax"
              {
                nativeBuildInputs = [
                  pkgs.lua
                  pkgs.nushell
                ];
              }
              ''
                luac -p ${hm.xdg.configFile."hypr/config.lua".source}
                nu --no-config-file -c 'nu-check ${
                  hm.xdg.configFile."nushell/env.nu".source
                } | if $in { } else { error make {msg: "invalid generated Nu"} }'
                nu --no-config-file -c 'source ${
                  hm.xdg.configFile."nushell/env.nu".source
                }; if $env.CONFIG_REGRESSION != (open --raw ${pkgs.writeText "expected-env" hm.home.sessionVariables.CONFIG_REGRESSION}) { error make {msg: "environment did not round-trip"} }'
                touch $out
              '';
        };
    };
}
