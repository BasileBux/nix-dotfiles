{
  description = "Python dev env";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python312;
      pythonEnv = python.withPackages (
        ps: with ps; [
          pip
          # jupyter
          # numpy
          # pandas
          # matplotlib
          # Add your dependencies here
        ]
      );
    in
    {
      apps.${system}.gen-rqs = {
        type = "app";
        program = toString (
          pkgs.writeShellScript "gen-rqs" ''
            #!/usr/bin/env bash
            set -euo pipefail
            ${pythonEnv}/bin/python -m pip freeze > requirements.txt
            echo "Generated requirements.txt"
          ''
        );
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pythonEnv ];
        shellHook = ''
          # If you want a jupyter notebook server, uncomment this
          # jupyter notebook --no-browser --IdentityProvider.token=""
          # exit

          # If you want a regular python env keep this
          export SHELL=$(getent passwd $USER | cut -d: -f7)
          exec $SHELL
        '';
      };
    };
}
