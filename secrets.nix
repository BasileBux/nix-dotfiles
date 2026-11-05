let
  inherit (builtins)
    attrNames
    concatMap
    filter
    listToAttrs
    map
    readDir
    ;

  fleet = import ./fleet.nix;
  inventory = import ./hosts;
  inherit (import ./modules/secrets/discovery.nix) listFilesRecursive isAge;
  policy = import ./modules/secrets/policy.nix;
  unique = builtins.foldl' (acc: key: if builtins.elem key acc then acc else acc ++ [ key ]) [ ];
  filterAttrs =
    pred: set:
    listToAttrs (
      map (name: {
        inherit name;
        value = set.${name};
      }) (filter (name: pred name set.${name}) (attrNames set))
    );

  # A host only needs an age recipient when a secret is encrypted for it, but
  # then it must have one: fail closed instead of silently dropping a recipient.
  hostKey =
    host:
    if !(inventory.machines ? ${host}) then
      throw "secrets.nix: '${host}' is not a host directory (hosts/${host}/identity.nix missing)"
    else if inventory.machines.${host}.key == null then
      throw "secrets.nix: hosts/${host}/identity.nix declares no key, but a secret is encrypted for ${host}"
    else
      inventory.machines.${host}.key;

  entry = path: recipients: {
    name = path;
    value = {
      file = ./. + "/${path}";
      publicKeys = unique recipients;
    };
  };
  hostSecrets = builtins.concatMap (
    host:
    map (path: entry path ([ (hostKey host) ] ++ fleet.keys-admin)) (
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
      entry path (map hostKey policy.${path}.hosts ++ fleet.keys-admin)
  ) shared;
  secrets = listToAttrs (hostSecrets ++ sharedSecrets);
in
# Force every recipient list so a missing host key fails when the inventory is
# evaluated, not lazily whenever the tooling happens to read publicKeys.
builtins.seq (builtins.map (secret: secret.publicKeys) (builtins.attrValues secrets)) secrets
