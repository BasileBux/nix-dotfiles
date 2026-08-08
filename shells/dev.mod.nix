{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      mkShell =
        attrs:
        pkgs.mkShell (
          attrs
          // {
            shellHook = ''
              export SHELL=$(getent passwd $USER | cut -d: -f7)
              exec $SHELL
            '';
          }
        );
      cShell = mkShell {
        packages = with pkgs; [
          gcc
          gcc_multi
          cmake
          gnumake
          clang
          gdb
        ];
      };
      rustShell = mkShell {
        packages = with pkgs; [
          rustc
          rustfmt
          rust-analyzer
          clippy
          cargo
        ];
      };
      nodeShell = mkShell {
        packages = with pkgs; [
          nodejs
          bun
        ];
      };
      goShell = mkShell {
        packages = with pkgs; [
          go
          gopls
          gotools
        ];
      };
      luaShell = mkShell {
        packages = with pkgs; [
          lua
          luarocks
          lua-language-server
        ];
      };
      typstShell = mkShell {
        packages = with pkgs; [
          typst
          tinymist
          typstyle
        ];
      };
      pythonShell = mkShell {
        packages = [
          (pkgs.sage.override { requireSageTests = false; })
          pkgs.python314
        ];
      };
    in
    {
      devShells = {
        c = cShell;
        rust = rustShell;
        node = nodeShell;
        go = goShell;
        lua = luaShell;
        typst = typstShell;
        python = pythonShell;
        dev = mkShell {
          inputsFrom = [
            cShell
            rustShell
            nodeShell
            goShell
            luaShell
            typstShell
            pythonShell
          ];
        };
      };
    };
}
