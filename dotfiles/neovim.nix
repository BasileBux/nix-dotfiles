{
  pkgs,
  lib,
  ...
}:
let
  treesitterParsers = with pkgs.tree-sitter-grammars; [
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
        lang = lib.removePrefix "tree-sitter-" (lib.getName p);
      in
      ''
        # Link parser .so file to parser/
        ln -s ${p}/parser $out/parser/${lang}.so

        # Link queries directory from your fork (if it exists)
        if [ -d "${nvim-treesitter-queries}/runtime/queries/${lang}" ]; then
          ln -s ${nvim-treesitter-queries}/runtime/queries/${lang} $out/queries/${lang}
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
}
