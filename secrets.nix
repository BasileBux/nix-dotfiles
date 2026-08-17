# Based almost verbatim on RGBCube's age/secrets config
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed

let
  inherit (builtins)
    attrNames
    attrValues
    concatMap
    elem
    filter
    foldl'
    listToAttrs
    readDir
    ;

  inherit (import ./modules/secrets/discovery.nix) listFilesRecursive isAge;

  singleton = value: [ value ];
  mapAttrs =
    f: set:
    listToAttrs (
      map (name: {
        inherit name;
        value = f name set.${name};
      }) (attrNames set)
    );
  filterAttrs =
    pred: set:
    listToAttrs (
      filter (name: pred name set.${name}) (attrNames set)
      |> map (name: {
        inherit name;
        value = set.${name};
      })
    );
  uniq = list: list |> foldl' (acc: item: if elem item acc then acc else acc ++ singleton item) [ ];

  # Import entities to get keys — replicate just the attrsets needed to avoid
  # dragging in the full module system (same hack ncc uses)
  entitiesImport =
    (import ./modules/entities.mod.nix {
      self = entitiesImport;
      lib.attrsets = { inherit attrValues filterAttrs mapAttrs; };
    }).flake;

  # The secret name is the path including .age, e.g.:
  #   modules/secrets/env/api-keys/anthropic.age → "modules/secrets/env/api-keys/anthropic.age"
  #   hosts/simon/password.age                  → "hosts/simon/password.age"
  # The .age suffix is kept so ragenix/agenix CLI can match filenames exactly.

  # Host secrets: hosts/<host>/*.age → encrypted for that host + admin keys
  hostSecrets =
    attrNames (readDir ./hosts)
    |> concatMap (
      host:
      listFilesRecursive "hosts/${host}" ./hosts/${host}
      |> filter isAge
      |> map (path: {
        name = path;
        value = {
          file = ./. + "/${path}";
          publicKeys = uniq (singleton entitiesImport.keys.${host} ++ entitiesImport.keys-admin);
        };
      })
    );

  # Module secrets: modules/**/*.age → encrypted for ALL keys
  moduleSecrets =
    listFilesRecursive "modules" ./modules
    |> filter isAge
    |> map (path: {
      name = path;
      value = {
        file = ./. + "/${path}";
        publicKeys = uniq <| attrValues entitiesImport.keys;
      };
    });
in
listToAttrs (hostSecrets ++ moduleSecrets)
