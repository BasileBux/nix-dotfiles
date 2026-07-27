{ lib
, stdenv
, fetchFromGitHub
, python3
}:

stdenv.mkDerivation {
  pname = "optmem";
  version = "0-unstable-2025-07-27";

  src = fetchFromGitHub {
    owner = "VictorTaelin";
    repo = "OptMem";
    rev = "d618a3a6265de3872fd5b7b71c8975bceb17c1d6";
    hash = "sha256-5Hn1kpiU1QOhEc6+mYKJKONQt8XUZKlqWUFCG7mLcjY=";
  };

  buildInputs = [ python3 ];

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
    longDescription = ''
      OptMem is a permanent, append-only memory for AI agents. A 426-token
      prompt, a script, plug and play. Memories form a binary merge tree over
      an append-only log. Records are fixed width, so position IS identity and
      every lookup is one seek. At a million memories (608 MB), wake takes
      0.03 s.
    '';
    homepage = "https://github.com/VictorTaelin/OptMem";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "memo";
    platforms = platforms.all;
  };
}
