{ lib, ... }: {
  # Flake-parts level option declaration (for self-referential host .mod.nix files)
  options.my.settings = lib.mkOption {
    type = lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
          description = "The primary username for this system";
        };
        hostname = lib.mkOption {
          type = lib.types.str;
          description = "The hostname for this machine";
        };
        desktop = lib.mkOption {
          type = lib.types.nullOr (
            lib.types.submodule {
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
                  description = "Commands to run on Hyprland startup";
                };
                mainMod = lib.mkOption {
                  type = lib.types.str;
                  default = "SUPER";
                  description = "Main modifier key for Hyprland keybinds";
                };
                extraConfig = lib.mkOption {
                  type = lib.types.lines;
                  default = "";
                  description = "Extra Hyprland Lua config appended as host.lua";
                };
              };
            }
          );
          default = null;
          description = "Desktop environment configuration. Set to null for headless/server machines.";
        };
        nixosVersion = lib.mkOption {
          type = lib.types.str;
          description = "The NixOS state version. DO NOT CHANGE THIS EVER";
        };
        accentColor = lib.mkOption {
          type = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
          default = "#fb8b1e";
          description = "Main accent color for prompts/theming, as #RRGGBB";
        };
        gitName = lib.mkOption {
          type = lib.types.str;
          default = "BasileBux";
          description = "Git and Jujutsu user name";
        };
        gitEmail = lib.mkOption {
          type = lib.types.str;
          default = "basile.buxtorf@ik.me";
          description = "Git and Jujutsu user email";
        };
        extraShellAliases = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Extra shell aliases appended to the built-in set";
        };
      };
    };
    description = "Per-host settings validated by the module system.";
  };

  # Also register as a NixOS module so that my.settings is available in nixosSystem
  config.commonModules.settings = { lib, ... }: {
    options.my.settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          username = lib.mkOption { type = lib.types.str; };
          hostname = lib.mkOption { type = lib.types.str; };
          desktop = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
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
              }
            );
            default = null;
          };
          nixosVersion = lib.mkOption { type = lib.types.str; };
          accentColor = lib.mkOption {
            type = lib.types.strMatching "^#[0-9a-fA-F]{6}$";
            default = "#fb8b1e";
          };
          gitName = lib.mkOption {
            type = lib.types.str;
            default = "BasileBux";
          };
          gitEmail = lib.mkOption {
            type = lib.types.str;
            default = "basile.buxtorf@ik.me";
          };
          extraShellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
          };
        };
      };
    };
  };
}
