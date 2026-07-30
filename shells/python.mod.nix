{ ... }: {
  perSystem =
    { pkgs, ... }:
    let
      python = pkgs.python312;
      pythonEnv = python.withPackages (ps: with ps; [ pip ]);
    in
    {
      apps.gen-rqs = {
        type = "app";
        program = toString (
          pkgs.writeShellScript "gen-rqs" ''
            set -euo pipefail
            ${pythonEnv}/bin/python -m pip freeze > requirements.txt
            echo "Generated requirements.txt"
          ''
        );
      };
      devShells.python = pkgs.mkShell {
        packages = [ pythonEnv ];
        shellHook = ''
          export SHELL=$(getent passwd $USER | cut -d: -f7)
          exec $SHELL
        '';
      };
    };
}
