{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "upsnap";
  version = "5.4.4";

  src = fetchurl {
    url = "https://github.com/seriousm4x/UpSnap/releases/download/${finalAttrs.version}/UpSnap_${finalAttrs.version}_linux_arm64.zip";
    hash = "sha256-o8QZ0SaItjRKDieoVAsviCfDyAzsyTwj8BZlGX+L72s=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 upsnap $out/bin/upsnap
    runHook postInstall
  '';

  meta = with lib; {
    description = "Remote wake-on-LAN / power control server (UpSnap)";
    homepage = "https://github.com/seriousm4x/UpSnap";
    license = licenses.mit;
    platforms = [ "aarch64-linux" ];
    mainProgram = "upsnap";
  };
})
