{
  pkgs,
  lib,
  ...
}:
let
  treesitterParsers = with pkgs.tree-sitter-grammars; [
    tree-sitter-bash
    tree-sitter-c
    tree-sitter-cpp
    tree-sitter-go
    tree-sitter-html
    tree-sitter-javascript
    tree-sitter-json
    tree-sitter-python
    tree-sitter-rust
    tree-sitter-typescript
    tree-sitter-typst
    tree-sitter-nix
    tree-sitter-markdown
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
  ];
}
