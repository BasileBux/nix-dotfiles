{ ... }: {
  flake.module.quickshell = {
    home =
      {
        config,
        settings,
        pkgs,
        osConfig,
        ...
      }:
      let
        cfg = osConfig.my.quickshell;

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
                readonly property var balancedCommand: ${builtins.toJSON (pp.setCommand ++ [ balanced ])}
                readonly property var performanceCommand: ${builtins.toJSON (pp.setCommand ++ [ perf ])}
                readonly property var getterCommand: ${builtins.toJSON pp.getterCommand}
            }
          '';
      in
      {
        home.packages = with pkgs; [
          quickshell
          kdePackages.qt5compat
          bluez
        ];
        xdg.configFile."quickshell" = {
          source = ../dotfiles/quickshell;
          recursive = true;
        };
        xdg.configFile."quickshell/MachineOverrides.qml".text = generateMachineOverrides cfg;
      };

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
                      type = lib.types.listOf lib.types.str;
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
  };
}
