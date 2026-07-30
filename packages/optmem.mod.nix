{ lib, ... }: {
  perSystem = { pkgs, ... }: {
    packages.optmem = pkgs.stdenv.mkDerivation {
      pname = "optmem";
      version = "0-unstable-2025-07-27";

      src = pkgs.fetchFromGitHub {
        owner = "VictorTaelin";
        repo = "OptMem";
        rev = "d618a3a6265de3872fd5b7b71c8975bceb17c1d6";
        hash = "sha256-5Hn1kpiU1QOhEc6+mYKJKONQt8XUZKlqWUFCG7mLcjY=";
      };

      buildInputs = [ pkgs.python3 ];

      dontBuild = true;

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        cp $src/memo $out/bin/memo
        chmod +x $out/bin/memo
        patchShebangs $out/bin/memo
        runHook postInstall
      '';

      meta = with lib; {
        description = "Permanent memory for AI agents — a script, plug and play";
        homepage = "https://github.com/VictorTaelin/OptMem";
        license = licenses.mit;
        mainProgram = "memo";
        platforms = platforms.all;
      };
    };
  };
}
