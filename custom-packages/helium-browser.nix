{ pkgs, ... }:

let
  mkAppImage = import ./mkAppImage.nix { inherit pkgs; };
  version = "0.11.3.2";
  pname = "helium";
in
mkAppImage {
  pname = pname;
  version = version;
  url = "https://github.com/imputnet/helium-linux/releases/dwnload/${version}/helium-${version}-x86_64.AppImage";
  hash = "sha256-5gdyKg12ZV2hpf0RL+eoJnawuW/J8NobiG+zEA0IOHA=";
}
# NOTE: To get the latest version (which should be updated regularly), run:
# curl -sSf https://api.github.com/repos/imputnet/helium-linux/releases/latest | jq -r '.tag_name'
