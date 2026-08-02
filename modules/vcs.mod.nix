{ self, lib, ... }: {
  flake.homeModules.vcs =
    {
      config,
      settings,
      pkgs,
      ...
    }:
    {
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings = {
          user.name = settings.gitName;
          user.email = settings.gitEmail;
          user.signingkey = "/home/${settings.username}/.ssh/id_ed25519.pub";
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
          user.name = settings.gitName;
          user.email = settings.gitEmail;
          ui = {
            default-command = "log";
            editor = "nvim";
            merge-editor = "meld";
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = "/home/${settings.username}/.ssh/id_ed25519.pub";
          };
          git.sign-on-push = true;
        };
      };
      home.packages =
        with pkgs;
        [
          gh
          jjui
          difftastic
        ]
        ++ lib.optionals (settings.desktop) [
          meld
        ];

    };
}
