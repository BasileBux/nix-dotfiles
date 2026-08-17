# Based almost verbatim on RGBCube's age/secrets config
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed
rec {
  inherit (builtins)
    attrNames
    concatMap
    match
    readDir
    ;

  singleton = value: [ value ];

  # Recursively list all regular files under a directory, relative to it
  listFilesRecursive =
    base: dir:
    let
      entries = readDir dir;
      names = attrNames entries;
    in
    names
    |> concatMap (
      name:
      if entries.${name} == "directory" then
        listFilesRecursive "${base}/${name}" "${dir}/${name}"
      else if entries.${name} == "regular" then
        singleton "${base}/${name}"
      else
        [ ]
    );

  isAge = name: match ".*\\.age$" name != null;
}
