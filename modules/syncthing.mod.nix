# Selecting this role enables Syncthing, deriving identities from the host
# inventory (hosts/<host>/identity.nix) and topology from fleet.nix. Sync uses
# the tailnet and local discovery, not global discovery, relays or NAT traversal.
{ self, ... }: {
  flake.module.syncthing-options = {
    nixos =
      {
        config,
        lib,
        ...
      }:
      {
        options.my.syncthing = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the selected Syncthing role.";
          };

          # Defaults come from the shared fleet inventory.
          machines = lib.mkOption {
            type =
              (import ../lib/fleet-types.nix {
                inherit lib;
                defaults = (import ../fleet.nix).defaults;
              }).machines;
            default = self.machines;
            description = "flake.machines registry (syncthing IDs + tailscale IPs).";
          };
          folders = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule (
                { name, ... }: {
                  options = {
                    path = lib.mkOption {
                      type = lib.types.str;
                      default = "~/${name}";
                    };
                    devices = lib.mkOption {
                      type = lib.types.nullOr (lib.types.listOf lib.types.str);
                      default = null;
                    };
                    ignorePatterns = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [ ];
                    };
                  };
                }
              )
            );
            default = self.syncthing.folders or { };
            description = "flake.syncthing.folders mesh topology.";
          };
          selfId = lib.mkOption {
            type = with lib.types; nullOr str;
            default = self.machines.${config.networking.hostName}.syncthing.id or null;
            description = "This machine's syncthing.id from the registry.";
          };

          snapshot.repos = lib.mkOption {
            type = with lib.types; listOf str;
            default = [ ];
            description = ''
              Paths (relative to the user's home) of jj repos to auto-snapshot
              hourly: when the working copy has uncommitted changes, `jj commit`
              records them as a new change.
            '';
          };
        };
      };
  };

  flake.module.syncthing = {
    imports = [
      self.flakeModules.syncthing-options
      self.flakeModules.secrets
    ];
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.my.syncthing;
        machines = cfg.machines;

        machineHasId = name: (machines.${name}.syncthing.id or null) != null;
        # Every mesh member: name -> { id, addresses }.
        machineIds = lib.filterAttrs (name: _: machineHasId name) machines;

        # A folder without an explicit device list is shared by the whole mesh.
        folderDevices = f: if (f.devices or null) == null then lib.attrNames machineIds else f.devices;

        meshFolders = lib.mapAttrs (name: f: {
          path = f.path or "~/${name}";
          devices = folderDevices f;
          ignorePatterns = f.ignorePatterns or [ ];
        }) cfg.folders;

        meshDevices = lib.mapAttrs (
          name: _:
          let
            ip = machines.${name}.tailscale.ip or null;
          in
          {
            id = machines.${name}.syncthing.id;
            addresses = lib.optionals (ip != null) [ "tcp://${ip}:22000" ] ++ [ "dynamic" ];
          }
        ) machineIds;

        # Node identity: cert/key age secrets define (and pin) the device ID.
        # Checked statically against the repo (flake source tree) instead of
        # config.age.secrets, whose existence check would self-recurse since
        # this module itself defines those secrets.
        certSecret = "hosts/${config.networking.hostName}/syncthing-cert.age";
        keySecret = "hosts/${config.networking.hostName}/syncthing-key.age";
        hasIdentity =
          builtins.pathExists (../hosts + "/${config.networking.hostName}/syncthing-cert.age")
          && builtins.pathExists (../hosts + "/${config.networking.hostName}/syncthing-key.age");
      in
      {
        config = lib.mkIf cfg.enable {
          assertions = [
            {
              assertion = cfg.selfId != null;
              message = "my.syncthing.enable is set but ${config.networking.hostName} has no syncthing.id in hosts/${config.networking.hostName}/identity.nix.";
            }
            {
              assertion = hasIdentity;
              message = "my.syncthing.enable is set but hosts/${config.networking.hostName}/syncthing-{cert,key}.age are missing; the declared device ID (${cfg.selfId}) is pinned by that cert.";
            }
            {
              assertion = lib.all machineHasId (lib.flatten (lib.mapAttrsToList (_: f: f.devices) meshFolders));
              message = "A syncthing folder lists a device whose hosts/<device>/identity.nix has no syncthing.id.";
            }
          ];

          services.syncthing = {
            enable = true;
            user = config.my.settings.username;
            # Module defaults hardcode /var/lib/syncthing regardless of user.
            group = config.users.users.${config.my.settings.username}.group;
            dataDir = "${config.users.users.${config.my.settings.username}.home}/.local/share/syncthing";
            cert = lib.mkIf hasIdentity config.age.secrets.${certSecret}.path;
            key = lib.mkIf hasIdentity config.age.secrets.${keySecret}.path;
            settings = {
              options = {
                globalAnnounceEnabled = false;
                relaysEnabled = false;
                natEnabled = false;
                urAccepted = -1;
                localAnnounceEnabled = true;
              };
              devices = meshDevices;
              folders = meshFolders;
            };
          };

          # syncthing's ExecStartPre (running as the user) copies these into
          # its config dir, so they must be user-readable.
          age.secrets = lib.mkIf hasIdentity {
            ${certSecret} = {
              owner = config.my.settings.username;
              mode = "0400";
            };
            ${keySecret} = {
              owner = config.my.settings.username;
              mode = "0400";
            };
          };

          networking.firewall.allowedTCPPorts = [ 22000 ];
          networking.firewall.allowedUDPPorts = [ 21027 ];

          systemd.services.jj-snapshot = lib.mkIf (cfg.snapshot.repos != [ ]) {
            description = "Hourly jj snapshot of synced repos";
            after = [ "local-fs.target" ];
            wantedBy = [ "multi-user.target" ];
            startAt = [ "hourly" ];
            serviceConfig = {
              Type = "oneshot";
              User = config.my.settings.username;
              SyslogIdentifier = "jj-snapshot";
            };
            # jj signs commits with the ssh backend; ssh-keygen must be on PATH.
            path = [ pkgs.openssh ];
            script =
              let
                jj = lib.getExe pkgs.jujutsu;
                home = config.users.users.${config.my.settings.username}.home;
              in
              lib.concatStringsSep "\n" (
                map (repo: ''
                  cd ${lib.escapeShellArg "${home}/${repo}"}
                  # `jj log` snapshots the working copy first, so `empty` is
                  # evaluated against its current state.
                  if [ "$(${jj} log -r @ --no-graph -T 'empty' 2>/dev/null)" = "false" ]; then
                    echo "snapshotting ${repo}"
                    ${jj} commit -m "auto: sync snapshot $(date -u +%Y-%m-%dT%H:%MZ)"
                  fi
                '') cfg.snapshot.repos
              );
          };

          systemd.timers.jj-snapshot = lib.mkIf (cfg.snapshot.repos != [ ]) {
            timerConfig.Persistent = lib.mkDefault true;
          };
        };
      };
  };
}
