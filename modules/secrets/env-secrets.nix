# Auto-discover age secrets under ./env and derive the env var name for each
# from its file path.
#
# Conventions:
#   - Every .age file under modules/secrets/env/ is exported as an env var.
#     Anything outside this directory is deliberately not exported
#   - The env var name is the uppercased filename (dashes -> underscores),
#     plus a suffix looked up from `dirSuffixes` by the parent directory's
#     basename.
#   - `overrides` lets a specific file opt out of the convention.
#   - Deriving the same env var name from two files is a build error.
#
# Returns a list of { path, name } where `path` is the age secret path
{ lib }:
let
  inherit (builtins)
    attrNames
    baseNameOf
    concatStringsSep
    dirOf
    filter
    foldl'
    head
    length
    map
    replaceStrings
    substring
    stringLength
    ;

  inherit (import ./discovery.nix) listFilesRecursive isAge;

  dirSuffixes = {
    "api-keys" = "_API_KEY";
  };

  overrides = { };

  toUpperSnake = s: lib.toUpper (replaceStrings [ "-" ] [ "_" ] s);

  stripSuffix =
    suffix: s:
    let
      sl = stringLength suffix;
      len = stringLength s;
    in
    if len >= sl && substring (len - sl) sl s == suffix then substring 0 (len - sl) s else s;

  deriveEnvName =
    path:
    let
      base = stripSuffix ".age" (baseNameOf path);
      name = toUpperSnake base;
      suffix = dirSuffixes.${baseNameOf (dirOf path)} or "";
    in
    "${name}${suffix}";

  discovered = listFilesRecursive "modules/secrets/env" ./env |> filter isAge;

  secrets = map (path: {
    inherit path;
    name = overrides.${path} or (deriveEnvName path);
  }) discovered;

  # env var name -> list of files deriving it
  byName = foldl' (acc: s: acc // { ${s.name} = (acc.${s.name} or [ ]) ++ [ s.path ]; }) { } secrets;

  collisions = filter (name: length byName.${name} > 1) (attrNames byName);
  emptyNames = filter (s: s.name == "") secrets;
in
if length collisions > 0 then
  throw "env-secrets: env var '${head collisions}' derived from multiple files: ${
    concatStringsSep ", " byName.${head collisions}
  }"
else if length emptyNames > 0 then
  throw "env-secrets: no env var name could be derived from ${(head emptyNames).path}"
else
  secrets
