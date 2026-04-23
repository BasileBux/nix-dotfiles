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

    # tree-sitter-nix
    # NOTE: Package seems rather abondoned and a bit broken. So I have a modified
    # version of the parser under `~/.local/share/nvim/site/parser` and `queries`
    # keep an eye on https://github.com/nix-community/tree-sitter-nix still.
    # Also using the queries from:
    # https://github.com/nvim-treesitter/nvim-treesitter/tree/main/runtime/queries/nix
  ];
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

        # Link queries directory to queries/{lang}/
        ln -s ${p}/queries $out/queries/${lang}
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
    # gopls
    # (lib.hiPrio gopls)
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
