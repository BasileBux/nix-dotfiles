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
}
