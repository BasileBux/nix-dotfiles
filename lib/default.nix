nixpkgsLib:
nixpkgsLib.extend (
  self: super: {
    # Generate a shell snippet that creates the given directories.
    # Usage: home.activation.createDirs = lib.hm.dag.entryAfter ["writeBoundary"] (myLib.mkXdgDirs dirs);
    mkXdgDirs = dirs: ''
      ${nixpkgsLib.concatMapStringsSep "\n" (d: "\$DRY_RUN_CMD mkdir -p '${d}'") dirs}
    '';
  }
)
