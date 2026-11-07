{ ... }: {
  perSystem =
    { pkgs, lib, ... }:
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
        packages =
          with pkgs;
          [
            gcc
            cmake
            gnumake
            clang
            gdb
            clang-tools
            cmake-language-server
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isx86 [ pkgs.gcc_multi ];
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
          typescript-language-server
          prettier
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
      qmlShell = mkShell {
        packages = with pkgs; [ kdePackages.qtdeclarative ];
      };
      typstShell = mkShell {
        packages = with pkgs; [
          typst
          tinymist
          typstyle
        ];
        TYPSTDIR = "/home/$USER/.local/share/typst/packages";
      };
      mathShell = mkShell {
        packages = [
          (pkgs.sage.override { requireSageTests = false; })
        ];
      };
      pythonShell = mkShell {
        packages = [
          pkgs.python314
          pkgs.basedpyright
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
        qml = qmlShell;
        typst = typstShell;
        python = pythonShell;
        math = mathShell;
        dev = mkShell {
          # Everything except math: sage alone is enormous.
          inputsFrom = [
            cShell
            rustShell
            nodeShell
            goShell
            luaShell
            qmlShell
            typstShell
            pythonShell
          ];
        };
      };
    };
}
