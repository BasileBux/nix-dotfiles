{ self, lib, ... }: {
  perSystem =
    { pkgs, system, ... }:
    let
      inventory = import ../hosts;
      hosts = lib.filterAttrs (
        _: host: host.pkgs.stdenv.hostPlatform.system == system
      ) self.nixosConfigurations;
      pass =
        name: ok:
        assert lib.assertMsg ok "Regression failed: ${name}";
        pkgs.runCommand name { } "touch $out";
      simon = self.nixosConfigurations.simon;
      kamina = self.nixosConfigurations.kamina;
      homeOf = host: host.config.home-manager.users.${host.config.my.settings.username};
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
            name = "simon";
            stateVersion = "25.05";
            modules = [ self.flakeModules.personal ];
          };
      changedUser = defaults.extendModules {
        modules = [ ({ lib, ... }: { my.settings.username = lib.mkForce "regression-user"; }) ];
      };
      changedHome = simon.extendModules {
        modules = [ ({ lib, ... }: { my.settings.homeDirectory = lib.mkForce "/srv/fleet-regression"; }) ];
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
            home-manager.users.${simon.config.my.settings.username}.home.sessionVariables.CONFIG_REGRESSION =
              ''spaces "quotes" 'single' \\backslash $literal'';
          }
        ];
      };
      hm = homeOf quoted;
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
            (homeOf changed).programs.git.settings.user.name == "Settings regression"
          );
          settings-defaults = pass "settings-defaults" (
            (homeOf defaults).programs.git.settings.user.name == defaults.config.my.settings.gitName
            && (homeOf defaults).home.stateVersion == "25.05"
          );
          inventory-defaults = pass "inventory-defaults-and-exceptions" (
            let
              # A host with no key and no overrides: identity.nix may be `{ }`.
              keyless = inventory.resolve "keyless" {
                tailscale.ip = "100.64.0.1";
              };
            in
            self.machines.simon.username == self.fleet.defaults.username
            && self.machines.yoko.username == "eugene"
            && inventory.hosts.yoko.ssh.hostname == "asbel.xyz"
            && self.nixosConfigurations.yoko.config.my.settings.username == self.machines.yoko.username
            && keyless.key == null
            && keyless.ssh.hostname == "keyless.${self.fleet.tailnet.domain}"
            && keyless.ssh.port == self.fleet.defaults.ssh.port
            && keyless.ssh.user == self.fleet.defaults.username
            && keyless.syncthing.id == null
            && lib.all (
              name:
              let
                host = self.nixosConfigurations.${name};
                user = host.config.my.settings.username;
              in
              user == self.machines.${name}.username
              && host.config.home-manager.users.${user}.home.username == user
              && host.config.age.identityPaths == [ "${host.config.users.users.${user}.home}/.ssh/${name}" ]
              && self.sshHosts.${name}.user == user
            ) (builtins.attrNames self.nixosConfigurations)
            &&
              lib.all
                (
                  name:
                  self.nixosConfigurations.${name}.config.services.openssh.ports == [ self.sshHosts.${name}.port ]
                )
                [
                  "kamina"
                  "genome"
                  "yoko"
                ]
            && self.sshHosts.buxtorf-synology.user == "gitt"
            && self.sshHosts.yoko.hostname == "asbel.xyz"
            && changedUser.config.home-manager.users.regression-user.home.username == "regression-user"
            && !(builtins.hasAttr defaults.config.my.settings.username changedUser.config.home-manager.users)
            && (homeOf changedHome).home.homeDirectory == "/srv/fleet-regression"
            && changedHome.config.age.identityPaths == [ "/srv/fleet-regression/.ssh/simon" ]
            && changedHome.config.my.smb.mountPoint == "/srv/fleet-regression/synology"
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
            && !((homeOf keyless).home.activation ? fonts-tx-02)
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
