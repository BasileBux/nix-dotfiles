{ self, ... }:
let
  treesitterParsers = (with self.pkgs or [ ]; [ ]) # will be resolved at eval time
  ;
in
{
  flake.homeModules.shell = self.homeModules.neovim;
  flake.homeModules.neovim =
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
      config = {
        home.packages = with pkgs; [
          neovim-wrapped
          ripgrep
          fd
          fzf
          gcc
          cargo
          rustc
          luarocks
          nodejs
          tree-sitter
          imagemagick
          ghostscript
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
          nixfmt-tree
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

        xdg.configFile."nvim".source = ../dotfiles/nvim;

        xdg.desktopEntries.nvim-terminal = {
          name = "Neovim";
          comment = "Edit text files in Neovim (terminal)";
          exec = "kitty -e nvim %F";
          terminal = false; # kitty itself is the terminal being launched; this is not the flag you set to true
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
