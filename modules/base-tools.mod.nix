{ self, ... }: {
  flake.nixosModules.base-tools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      wget
      curl
      dig
      openssh

      jq
      btop
      file
      bat
      xxd

      unzip
      zip

      man-pages
      man-pages-posix
    ];
  };
}
