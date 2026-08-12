{ inputs, ... }: {
  flake.module.xdg = {
    nixos = {
      nix.settings.use-xdg-base-directories = true;
    };
    home =
      {
        config,
        lib,
        ...
      }:
      let
        inherit (config.xdg)
          configHome
          dataHome
          stateHome
          cacheHome
          ;

        xdgDirs = [
          # Rust
          "${dataHome}/cargo"
          "${dataHome}/rustup"

          # Go
          "${dataHome}/go"

          # Node / npm
          "${dataHome}/npm"
          "${dataHome}/npm-global"
          "${configHome}/npm"
          "${stateHome}/node"

          # Bun
          "${dataHome}/bun"
          "${stateHome}/bun"

          # Python
          "${stateHome}/python"
          "${configHome}/ipython"
          "${configHome}/jupyter"
          "${configHome}/keras"

          # SageMath
          "${configHome}/sage"

          # Java / Gradle / Android
          "${dataHome}/gradle"
          "${dataHome}/android"
          "${configHome}/java"

          # ripgrep
          "${configHome}/ripgrep"

          # less
          "${stateHome}/less"

          # sqlite
          "${stateHome}/sqlite"

          # Radicle
          "${dataHome}/radicle"

          # PlatformIO
          "${dataHome}/platformio"

          # Yarn
          "${configHome}/yarn"
          "${cacheHome}/yarn"

          # wget
          "${dataHome}/wget"

          # terminfo
          "${dataHome}/terminfo"

          # pi coding agent
          "${configHome}/pi"

          # optmem
          "${stateHome}/optmem"

          # zsh
          "${stateHome}/zsh"
          "${cacheHome}/zsh"
        ];
      in
      {
        xdg.userDirs = {
          enable = true;
          createDirectories = false;
          setSessionVariables = false;
        };
        xdg.mimeApps.enable = true;

        home.activation.createXdgDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          inputs.self.lib.mkXdgDirs xdgDirs
        );

        home.sessionVariables = {
          XDG_CONFIG_HOME = configHome;
          XDG_DATA_HOME = dataHome;
          XDG_STATE_HOME = stateHome;
          XDG_CACHE_HOME = cacheHome;

          # Rust
          CARGO_HOME = "${dataHome}/cargo";
          RUSTUP_HOME = "${dataHome}/rustup";

          # Go
          GOPATH = "${dataHome}/go";

          # Node / npm
          npm_config_cache = "${dataHome}/npm";
          npm_config_prefix = "${dataHome}/npm-global";
          npm_config_userconfig = "${configHome}/npm/npmrc";
          NODE_REPL_HISTORY = "${stateHome}/node/history";

          # Bun
          BUN_INSTALL = "${dataHome}/bun";
          BUN_REPL_HISTORY = "${stateHome}/bun/history";

          # Python
          PYTHON_HISTORY = "${stateHome}/python/history";
          IPYTHONDIR = "${configHome}/ipython";
          JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
          KERAS_HOME = "${configHome}/keras";

          # SageMath
          DOT_SAGE = "${configHome}/sage";

          # Java / Gradle / Android
          GRADLE_USER_HOME = "${dataHome}/gradle";
          ANDROID_USER_HOME = "${dataHome}/android";
          _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configHome}/java";

          # ripgrep
          RIPGREP_CONFIG_PATH = "${configHome}/ripgrep/config";

          # less
          LESSHISTFILE = "${stateHome}/less/history";

          # sqlite
          SQLITE_HISTORY = "${stateHome}/sqlite/history";

          # Radicle
          RAD_HOME = "${dataHome}/radicle";

          # PlatformIO
          PLATFORMIO_CORE_DIR = "${dataHome}/platformio";

          # Yarn
          YARN_CONFIG_DIR = "${configHome}/yarn";
          YARN_CACHE_FOLDER = "${cacheHome}/yarn";

          # wget
          WGET_HSTS = "${dataHome}/wget/hsts";

          # terminfo
          TERMINFO_DIRS = "${dataHome}/terminfo";

          # pi coding agent
          PI_CODING_AGENT_DIR = "${configHome}/pi";

          # optmem
          MEMORY_DIR = "${stateHome}/optmem";

          # zsh
          ZSH_COMPDUMP = "${cacheHome}/zsh/zcompdump";
        };
      };
  };
}
