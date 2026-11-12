{
  flake.module.vcs = {
    nixos = { config, lib, ... }: {
      options.my.vcs = lib.mkOption {
        type = lib.types.submodule {
          options = {
            signingkey = lib.mkOption {
              type = lib.types.str;
              default = "${config.my.settings.homeDirectory}/.ssh/id_ed25519.pub";
              description = "Git and jj signing key path";
            };
          };
        };
        default = { };
        description = "VCS module settings";
      };
    };
    home =
      {
        config,
        pkgs,
        osConfig,
        ...
      }:
      {
        programs.git = {
          enable = true;
          lfs.enable = true;
          settings = {
            user.name = osConfig.my.settings.gitName;
            user.email = osConfig.my.settings.gitEmail;
            user.signingkey = osConfig.my.vcs.signingkey;
            core.editor = "nvim";
            alias.pushall = "!git push origin && git push gh main";
          };
          signing = {
            format = "ssh";
            signByDefault = true;
          };
        };
        home.sessionVariables.GIT_EXTERNAL_DIFF = "difft";

        programs.jujutsu = {
          enable = true;
          settings = {
            user.name = osConfig.my.settings.gitName;
            user.email = osConfig.my.settings.gitEmail;
            ui = {
              default-command = "log"; # `jj log -r ::` for the full log
              editor = "nvim";
            };
            signing = {
              behavior = "own";
              backend = "ssh";
              key = osConfig.my.vcs.signingkey;
            };
            revsets.git-sign-on-push = "~signed() & mine()";
          };
        };
        home.packages = with pkgs; [
          gh
          jjui
          difftastic
        ];
      };
  };
}
