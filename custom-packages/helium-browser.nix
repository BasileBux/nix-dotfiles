{ pkgs, ... }:

let
  mkAppImage = import ./mkAppImage.nix { inherit pkgs; };
  version = "0.11.7.1";
  pname = "helium";
in
mkAppImage {
  pname = pname;
  version = version;
  url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
  hash = "sha256-qzc135IP5F2btxtOMUGMz+0azJhYL9KI0lcPG2KjcxU=";
}
# NOTE: To get the latest version (which should be updated regularly), run:
# curl -sSf https://api.github.com/repos/imputnet/helium-linux/releases/latest | jq -r '.tag_name'
