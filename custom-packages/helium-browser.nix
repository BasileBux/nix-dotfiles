{ pkgs, ... }:

let
  mkAppImage = import ./mkAppImage.nix { inherit pkgs; };
  version = "0.8.1.1";
  pname = "helium";
in mkAppImage {
  pname = pname;
  version = version;
  url =
    "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
  hash = "sha256-n1wn80h9O7GpZz4AygNSKMcilX8lr6fJkiQBBPPQXok=";
}
# NOTE: To get the latest version (which should be updated regularly), run:
# curl -sSf https://api.github.com/repos/imputnet/helium-linux/releases/latest | jq -r '.tag_name'

