{ ... }: {
  flake.module.quickshell = {
    nixos =
      { pkgs, lib, ... }:
      {
        options.my.quickshell = lib.mkOption {
          type = lib.types.submodule {
            options = {
              powerProfiles = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    setCommand = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [
                        "powerprofilesctl"
                        "set"
                      ];
                      description = "Command prefix for setting a power profile. The profile name is appended.";
                    };
                    profiles = lib.mkOption {
                      type = lib.types.addCheck (lib.types.listOf lib.types.str) (
                        profiles: builtins.length profiles == 3
                      );
                      default = [
                        "power-saver"
                        "balanced"
                        "performance"
                      ];
                      description = "Power profile names. Index 0 = eco, 1 = balanced, 2 = performance.";
                    };
                    getterCommand = lib.mkOption {
                      type = lib.types.listOf lib.types.str;
                      default = [
                        "powerprofilesctl"
                        "get"
                      ];
                      description = "Command to query the currently active power profile.";
                    };
                  };
                };
                default = { };
                description = "Machine-specific power profile configuration for Quickshell.";
              };
            };
          };
          default = { };
          description = "Machine-specific Quickshell configuration. Fully optional — defaults work with power-profiles-daemon.";
        };
        config = {
          services.upower.enable = true;
        };
      };

    home =
      {
        config,
        pkgs,
        osConfig,
        lib,
        ...
      }:
      let
        cfg = osConfig.my.quickshell;

        # Hosts shown by the palette's Remote view. target is the ssh alias
        # (see ssh.mod.nix). allowPower exposes reboot/shutdown buttons for
        # hosts where wheel has passwordless sudo. Hosts without tmux
        # (tmux = false) open a plain ssh session instead.
        remoteHosts = [
          {
            name = "kamina";
            role = "Desktop · VM host";
            allowPower = true;
          }
          {
            name = "genome";
            role = "Home server (RPi5)";
            allowPower = true;
          }
          {
            name = "yoko";
            role = "VPS · asbel.xyz";
            allowPower = false;
          }
          {
            name = "buxtorf-synology";
            role = "NAS";
            allowPower = false;
            tmux = false;
          }
        ];

        generateRemoteHosts = map (
          h:
          "{ name: ${builtins.toJSON h.name}, target: ${
            builtins.toJSON (h.target or h.name)
          }, role: ${builtins.toJSON h.role}, allowPower: ${
            if h.allowPower or false then "true" else "false"
          }, tmux: ${if h.tmux or true then "true" else "false"} },"
        ) remoteHosts;

        generateMachineOverrides =
          c:
          let
            pp = c.powerProfiles;
            eco = builtins.elemAt pp.profiles 0;
            balanced = builtins.elemAt pp.profiles 1;
            perf = builtins.elemAt pp.profiles 2;
          in
          ''
                        import Quickshell
                        import QtQuick

                        QtObject {
                            readonly property var profiles: ${builtins.toJSON pp.profiles}
                            readonly property var ecoCommand: ${builtins.toJSON (pp.setCommand ++ [ eco ])}
                            readonly property var balancedCommand: ${
                              builtins.toJSON (pp.setCommand ++ [ balanced ])
                            }
                            readonly property var performanceCommand: ${
                              builtins.toJSON (pp.setCommand ++ [ perf ])
                            }
                            readonly property var getterCommand: ${builtins.toJSON pp.getterCommand}
                            readonly property var remoteHosts: [
            ${lib.concatStringsSep "\n" generateRemoteHosts}
                            ]
                        }
          '';
      in
      {
        home.packages = with pkgs; [
          quickshell
          kdePackages.qt5compat
          bluez
          libnotify
        ];
        xdg.configFile."quickshell" = {
          source = ../config/quickshell;
          recursive = true;
        };
        xdg.configFile."quickshell/MachineOverrides.qml".text = generateMachineOverrides cfg;

        # Run the shell as a systemd user service, managed by the Wayland
        # session: started on graphical-session.target (activated by uwsm),
        # restarted on crash. Reload with: systemctl --user restart quickshell
        systemd.user.services.quickshell = {
          Unit = {
            Description = "Quickshell desktop shell";
            After = [ "graphical-session.target" ];
            # Headroom for monitor-hotplug restart bursts; the default of 5
            # starts per 10s once latched the unit into a failed state.
            StartLimitBurst = 15;
          };
          Service = {
            Type = "exec";
            # Native-looking file dialogs through the desktop portal instead of
            # Qt's fallback light theme (white-on-white against the shell theme)
            Environment = [ "QT_QPA_PLATFORMTHEME=xdgdesktopportal" ];
            ExecStart = "${lib.getExe pkgs.quickshell}";
            Restart = "on-failure";
            RestartSec = 3;
            Slice = "app-graphical.slice";
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
  };
}
