{
  inputs,
  ...
}:
let
  hypridleModule = {
    services.hypridle.enable = true;
  };
in
{
  flake.module.hyprland = {
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        cfg = config.my.hyprland;
        monitorSubmodule = lib.types.submodule {
          options = {
            description = lib.mkOption {
              type = lib.types.str;
              description = "EDID description of the monitor (as shown by `hyprctl monitors`).";
            };
            mode = lib.mkOption {
              type = lib.types.str;
              description = "Native mode, e.g. \"2560x1600@60.00Hz\".";
            };
            scale = lib.mkOption {
              type = lib.types.str;
            };
            builtin = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this is a builtin laptop panel. At most one monitor may be builtin.";
            };
            mirror = lib.mkOption {
              type = lib.types.nullOr (
                lib.types.submodule {
                  options = {
                    mode = lib.mkOption {
                      type = lib.types.str;
                      description = "16:9 mode the builtin panel advertises, used when mirroring unknown outputs.";
                    };
                    scale = lib.mkOption { type = lib.types.str; };
                  };
                }
              );
              default = null;
              description = "Mode/scale to force on the builtin panel while mirroring unknown outputs. Only valid on the builtin monitor.";
            };
          };
        };
      in
      {
        options.my.hyprland = lib.mkOption {
          type = lib.types.submodule {
            options = {
              monitors = lib.mkOption {
                type = lib.types.listOf monitorSubmodule;
                description = ''
                  Known monitors, ordered by priority. The first known connected
                  monitor is always the one enabled; everything else is disabled.
                  If only unknown outputs are connected and a builtin panel is
                  present, the builtin drives and all unknowns mirror onto it.
                '';
              };
              brightness = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    monitor = lib.mkOption { type = lib.types.str; };
                    keyboard = lib.mkOption { type = lib.types.str; };
                  };
                };
              };
              startup = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              mainMod = lib.mkOption {
                type = lib.types.str;
                default = "SUPER";
              };
              extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
              };
            };
          };
        };
        imports = [ hypridleModule ];
        config = {
          assertions = [
            {
              assertion = lib.length (lib.filter (m: m.builtin) cfg.monitors) <= 1;
              message = "my.hyprland.monitors: at most one monitor may be marked as builtin";
            }
            {
              assertion = lib.all (m: m.builtin || m.mirror == null) cfg.monitors;
              message = "my.hyprland.monitors: `mirror` is only valid on the monitor marked as builtin";
            }
          ];
          nix.settings = {
            substituters = [ "https://hyprland.cachix.org" ];
            trusted-substituters = [ "https://hyprland.cachix.org" ];
            trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
          };

          programs.hyprland = {
            enable = true;
            package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            withUWSM = true;
          };

          programs.uwsm.enable = true;
        };
      };

    home =
      {
        config,
        pkgs,
        lib,
        osConfig,
        ...
      }:
      let
        input-hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

        inherit (osConfig.my) hyprland;

        luaString = v: ''"${v}"'';

        luaConfig =
          let
            ms = hyprland.monitors;
            b = hyprland.brightness;

            luaMonitor =
              m:
              "\t\t{ description = ${luaString m.description}, mode = ${luaString m.mode}, scale = ${luaString m.scale}, builtin = ${lib.boolToString m.builtin}, mirror = ${
                if m.mirror == null then
                  "nil"
                else
                  "{ mode = ${luaString m.mirror.mode}, scale = ${luaString m.mirror.scale} }"
              } }";
          in
          ''
            return {
            	monitors = {
            ${builtins.concatStringsSep ",\n" (map luaMonitor ms)}
            	},
            	brightness = {
            		monitor = ${luaString b.monitor},
            		keyboard = ${luaString b.keyboard},
            	},
            	startup = {
            ${builtins.concatStringsSep "" (map (cmd: "		${luaString cmd},") hyprland.startup)}
            	},
            	mainMod = ${luaString hyprland.mainMod},
            }
          '';
      in
      {
        home.packages = with pkgs; [
          wl-clipboard
          playerctl
          grim
          slurp
          brightnessctl
          zenity
        ];

        home.pointerCursor = {
          enable = true;
          gtk.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        home.sessionVariables = {
          HYPRLAND_STUBS = "${input-hyprland}/share/hypr/stubs";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
          NIXOS_OZONE_WL = "1";
        };

        xdg.configFile."hypr/hyprland.lua".source = ../config/hypr/hyprland.lua;

        xdg.configFile."hypr/config.lua".text = luaConfig;

        xdg.configFile."hypr/host.lua".text = hyprland.extraConfig;

        xdg.configFile."hypr/lua".source = ../config/hypr/lua;

        home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
            ${pkgs.hyprland}/bin/hyprctl reload
          fi
        '';
      };
  };
}
