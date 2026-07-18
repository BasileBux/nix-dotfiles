{
  pkgs,
  config,
  lib,
  settings,
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
    ++ [
      pkgs.vimPlugins.nvim-treesitter-parsers.qmljs
    ];

  # Using queries from my fork of nvim-treesitter because even if archived, the
  # queries are good and I can fix them if needed.
  nvim-treesitter-queries = pkgs.fetchFromGitHub {
    owner = "BasileBux";
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
        # Link parser .so file to parser/
        # tree-sitter-grammars exposes ${p}/parser as the .so file directly,
        # vimPlugins.nvim-treesitter-parsers exposes it as a directory.
        if [ -f "${p}/parser" ]; then
          ln -s ${p}/parser $out/parser/${lang}.so
        elif [ -d "${p}/parser" ]; then
          for so in ${p}/parser/*.so; do
            [ -f "$so" ] && ln -s "$so" $out/parser/$(basename "$so")
          done
        fi

        # Prefer queries from your fork, fall back to the grammar package
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
in
{
  home.packages = with pkgs; [
    neovim-wrapped
    ripgrep
    fd
    fzf
    gcc
    cargo
    rustc
    luarocks
    tree-sitter
    imagemagick
    ghostscript

    # lsp and formatters
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
    NVIM_UNDODIR = "/home/${settings.username}/.local/share/nvim/undo";
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${settings.configPath}/dotfiles/nvim";
}
