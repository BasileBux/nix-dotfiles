let
  inherit (builtins)
    attrNames
    attrValues
    filter
    listToAttrs
    map
    readDir
    ;
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
      map (name: {
        inherit name;
        value = set.${name};
      }) (filter (name: pred name set.${name}) (attrNames set))
    );
  inventory = import ./lib/inventory.nix {
    lib.attrsets = { inherit attrValues filterAttrs mapAttrs; };
  };
  inherit (import ./modules/secrets/discovery.nix) listFilesRecursive isAge;
  policy = import ./modules/secrets/policy.nix;
  unique = builtins.foldl' (acc: key: if builtins.elem key acc then acc else acc ++ [ key ]) [ ];
  entry = path: recipients: {
    name = path;
    value = {
      file = ./. + "/${path}";
      publicKeys = unique recipients;
    };
  };
  hostSecrets = builtins.concatMap (
    host:
    map (path: entry path ([ inventory.machines.${host}.key ] ++ inventory.keys-admin)) (
      filter isAge (listFilesRecursive "hosts/${host}" ./hosts/${host})
    )
  ) (attrNames (filterAttrs (_: kind: kind == "directory") (readDir ./hosts)));
  shared = filter isAge (
    listFilesRecursive "modules" ./modules ++ listFilesRecursive "packages/fonts" ./packages/fonts
  );
  sharedSecrets = map (
    path:
    if !(policy ? ${path}) then
      throw "Missing explicit secret policy for ${path}"
    else
      entry path (map (host: inventory.machines.${host}.key) policy.${path}.hosts ++ inventory.keys-admin)
  ) shared;
in
listToAttrs (hostSecrets ++ sharedSecrets)
