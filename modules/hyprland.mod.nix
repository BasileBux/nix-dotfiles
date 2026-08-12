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
      { pkgs, lib, ... }:
      {
        options.my.hyprland = lib.mkOption {
          type = lib.types.submodule {
            options = {
              monitors = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    primary = lib.mkOption {
                      type = lib.types.submodule {
                        options = {
                          description = lib.mkOption { type = lib.types.str; };
                          mode = lib.mkOption { type = lib.types.str; };
                          position = lib.mkOption { type = lib.types.str; };
                          scale = lib.mkOption { type = lib.types.str; };
                          mirror = lib.mkOption {
                            type = lib.types.submodule {
                              options = {
                                mode = lib.mkOption { type = lib.types.str; };
                                scale = lib.mkOption { type = lib.types.str; };
                              };
                            };
                          };
                        };
                      };
                    };
                    secondary = lib.mkOption {
                      type = lib.types.submodule {
                        options = {
                          description = lib.mkOption { type = lib.types.str; };
                          mode = lib.mkOption { type = lib.types.str; };
                          position = lib.mkOption { type = lib.types.str; };
                          scale = lib.mkOption { type = lib.types.str; };
                        };
                      };
                    };
                  };
                };
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
        osConfig,
        ...
      }:
      let
        input-hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

        inherit (osConfig.my) hyprland;

        luaString = v: ''"${v}"'';

        luaConfig =
          let
            m = hyprland.monitors;
            b = hyprland.brightness;
          in
          ''
            return {
            	monitors = {
            		primary = {
            			description = ${luaString m.primary.description},
            			mode = ${luaString m.primary.mode},
            			position = ${luaString m.primary.position},
            			scale = ${luaString m.primary.scale},
            			mirror = {
            				mode = ${luaString m.primary.mirror.mode},
            				scale = ${luaString m.primary.mirror.scale},
            			},
            		},
            		secondary = {
            			description = ${luaString m.secondary.description},
            			mode = ${luaString m.secondary.mode},
            			position = ${luaString m.secondary.position},
            			scale = ${luaString m.secondary.scale},
            		},
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

        xdg.configFile."hypr/hyprland.lua".source = ../dotfiles/hypr/hyprland.lua;

        xdg.configFile."hypr/config.lua".text = luaConfig;

        xdg.configFile."hypr/host.lua".text = hyprland.extraConfig;

        xdg.configFile."hypr/lua".source = ../dotfiles/hypr/lua;

        home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
            ${pkgs.hyprland}/bin/hyprctl reload
          fi
        '';
      };
  };
}
