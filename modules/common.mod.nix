{ self, ... }: {
  flake.nixosModules.common = { pkgs, ... }: {
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      bat
      xxd
      dig
      man-pages
      man-pages-posix
      perf
      tree
      gcc
      gcc_multi
      cmake
      gnumake
      clang
      gdb
      rustc
      rustfmt
      rust-analyzer
      clippy
      nodejs
      bun
      go
      lua
      python314
    ];
  };
}
