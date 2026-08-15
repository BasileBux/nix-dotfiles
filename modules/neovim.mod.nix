{ ... }:
{
  flake.module.neovim = {
    home =
      {
        config,
        settings,
        pkgs,
        lib,
        ...
      }:
      let
        treesitterParsers =
          (with pkgs.tree-sitter-grammars; [
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-go
            tree-sitter-rust
            tree-sitter-javascript
            tree-sitter-typescript
            tree-sitter-html
            tree-sitter-json
            tree-sitter-yaml
            tree-sitter-toml
            tree-sitter-bash
            tree-sitter-nu
            tree-sitter-python
            tree-sitter-typst
            tree-sitter-nix
          ])
          ++ [ pkgs.vimPlugins.nvim-treesitter-parsers.qmljs ];

        nvim-treesitter-queries = pkgs.fetchFromGitHub {
          owner = "nvim-treesitter";
          repo = "nvim-treesitter";
          rev = "main";
          hash = "sha256-PQR6tFt4lCrAZNQG7BLMD1IiCKja9wDS1S4laGJf/HE=";
        };

        parserBundle = pkgs.runCommand "nvim-treesitter-parsers" { } ''
          mkdir -p $out/parser
          mkdir -p $out/queries
          ${lib.concatMapStrings (
            p:
            let
              name = lib.getName p;
              lang =
                if lib.hasPrefix "tree-sitter-" name then
                  lib.removePrefix "tree-sitter-" name
                else if lib.hasPrefix "nvim-treesitter-grammar-" name then
                  lib.removePrefix "nvim-treesitter-grammar-" name
                else
                  name;
            in
            ''
              if [ -f "${p}/parser" ]; then
                ln -s ${p}/parser $out/parser/${lang}.so
              elif [ -d "${p}/parser" ]; then
                for so in ${p}/parser/*.so; do
                  [ -f "$so" ] && ln -s "$so" $out/parser/$(basename "$so")
                done
              fi
              if [ -d "${nvim-treesitter-queries}/runtime/queries/${lang}" ]; then
                ln -s ${nvim-treesitter-queries}/runtime/queries/${lang} $out/queries/${lang}
              elif [ -d "${p}/queries" ]; then
                ln -s ${p}/queries $out/queries/${lang}
              fi
            ''
          ) treesitterParsers}
        '';

        neovim-wrapped = pkgs.writeShellScriptBin "nvim" ''
          exec ${pkgs.neovim-unwrapped}/bin/nvim --cmd "set rtp^=${parserBundle}" "$@"
        '';

        mimeTypes = [
          "text/markdown"
          "text/plain"
        ];
        inherit (lib.attrsets) genAttrs;
        inherit (lib.trivial) const;
      in
      {
        home.packages = with pkgs; [
          # minimal deps to run and build plugins
          neovim-wrapped
          ripgrep
          fd
          fzf
          gcc
          cargo
          rustc
          nodejs
          imagemagick
          ghostscript

          # LSPs and formatters: I like to always have them but we could do dev env
          # only and install them only when needed.
          basedpyright
          cmake-language-server
          stylua
          clang-tools
          gopls
          gotools
          ltex-ls
          lua-language-server
          nil
          nixfmt
          prettier
          kdePackages.qtdeclarative
          tinymist
          typescript-language-server
          typstyle
          marksman
          bash-language-server
        ];

        home.sessionVariables = {
          NVIM_UNDODIR = "${config.home.homeDirectory}/.local/share/nvim/undo";
          SUDO_EDITOR = "nvim";
          EDITOR = "nvim";
        };

        xdg.configFile."nvim".source = ../config/nvim;

        xdg.desktopEntries.nvim-terminal = {
          name = "Neovim";
          comment = "Edit text files in Neovim (terminal)";
          exec = "kitty -e nvim %F";
          terminal = false; # We execute kitty already
          icon = "nvim";
          type = "Application";

          mimeType = [
            "text/plain"
            "text/markdown"
          ];
          categories = [
            "Utility"
            "TextEditor"
          ];
        };
        xdg.mimeApps.defaultApplications = genAttrs mimeTypes (const "nvim-terminal.desktop");
      };
  };
}
