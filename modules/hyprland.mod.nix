{
  self,
  lib,
  inputs,
  ...
}:
let
  hypridleModule = { ... }: {
    services.hypridle.enable = true;
  };
in
{
  config = {
    flake.nixosModules.desktop = self.nixosModules.hyprland;

    flake.nixosModules.hyprland = { inputs, pkgs, ... }: {
      imports = [ hypridleModule ];
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };

      programs.hyprland.enable = true;
      programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    };

    flake.homeModules.hyprland =
      {
        config,
        pkgs,
        settings,
        ...
      }:
      let
        input-hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

        inherit (settings) desktop;

        luaString = v: ''"${v}"'';

        luaConfig =
          let
            m = desktop.monitors;
            b = desktop.brightness;
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
            ${builtins.concatStringsSep "" (map (cmd: "		${luaString cmd},") desktop.startup)}
            	},
            	mainMod = ${luaString desktop.mainMod},
            }
          '';
      in
      {
        home.packages = with pkgs; [
          bibata-cursors
          hyprcursor
          playerctl
          grim
          slurp
          brightnessctl
        ];

        home.sessionVariables.HYPRLAND_STUBS = "${input-hyprland}/share/hypr/stubs";

        xdg.configFile."hypr/hyprland.lua".source = ../dotfiles/hypr/hyprland.lua;

        xdg.configFile."hypr/config.lua".text = luaConfig;

        xdg.configFile."hypr/host.lua".text = desktop.extraConfig;

        xdg.configFile."hypr/lua".source = ../dotfiles/hypr/lua;

        home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
            ${pkgs.hyprland}/bin/hyprctl reload
          fi
        '';
      };
  };
}
