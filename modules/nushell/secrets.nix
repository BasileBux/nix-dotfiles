{ osConfig, lib }:
let
  # Auto-discovered secrets under modules/secrets/env/, each with its
  # derived env var name (see modules/secrets/env-secrets.nix).
  envSecrets = import ../secrets/env-secrets.nix { inherit lib; };

  secretLine = s:
    "$env.${s.name} = (open ${osConfig.age.secrets.${s.path}.path} | str trim)";
in
(builtins.concatStringsSep "\n" (map secretLine envSecrets)) + "\n"
