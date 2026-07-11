{
  pkgs,
  ...
}:

{
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
    difftastic

    # C / C++
    gcc
    gcc_multi
    cmake
    gnumake
    clang
    gdb

    # Rust
    rustc
    rustfmt
    rust-analyzer
    clippy

    # js
    nodejs
    bun

    # Misc dev deps
    go
    lua
    python314
  ];
}
