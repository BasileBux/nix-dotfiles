{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.strings) concatLines;

  # Merge NixOS environment.{variables,sessionVariables} with
  # home.sessionVariables.  Simple $references ($HOME,
  # $(id -u)) are resolved in Nix; bash handles the remaining
  # parameter expansions like ${VAR:-fallback}.
  allSessionVars =
    (osConfig.environment.variables or { })
    // (osConfig.environment.sessionVariables or { })
    // config.home.sessionVariables;

  # Resolve known shell references at build time so bash in the
  # sandbox (which has different HOME, XDG_RUNTIME_DIR, etc.)
  # doesn't produce wrong values.  Remaining ${VAR:-...}
  # expansions are handled by bash after we control the env.
  resolveShellRefs =
    let
      homeDir = config.home.homeDirectory;
      uid =
        let
          fromHome = config.home.uid;
          fromUsers = osConfig.users.users.${config.home.username}.uid or null;
        in
        toString (
          if fromHome != null then
            fromHome
          else if fromUsers != null then
            fromUsers
          else
            1000
        );
    in
    val:
    builtins.replaceStrings [ "$(id -u)" "$HOME" "\${HOME}" ] [ uid homeDir homeDir ] (toString val);

  varDefs = concatLines (
    lib.mapAttrsToList (name: value: "${name}=${resolveShellRefs value}") allSessionVars
  );
  varNames = builtins.attrNames allSessionVars;
in
pkgs.runCommand "nushell-resolved-env.nu"
  {
    nativeBuildInputs = [ pkgs.bash ];
    HOME = config.home.homeDirectory;
  }
  (/* bash */ ''
    # Unset XDG_RUNTIME_DIR so {XDG_RUNTIME_DIR:-...}
    # fallbacks (e.g. for TMUX_TMPDIR) use the hardcoded
    # /run/user/<UID> we already substituted for $(id -u).
    unset XDG_RUNTIME_DIR

    # Write all var definitions into a script.  The heredoc
    # delimiter is quoted so bash does *not* expand anything
    # on write; expansion happens on 'source' below.
    cat > /tmp/session-vars.sh <<'ENDVAREOF'
    ${varDefs}
    ENDVAREOF

    set -a
    source /tmp/session-vars.sh
    set +a

    # Output nushell-compatible env vars (escaping " and \)
    for varname in ${lib.concatStringsSep " " (map lib.escapeShellArg varNames)}; do
      printf '$env.%s = "%s"\n' \
        "$varname" \
        "''${!varname//\\/\\\\}"
    done > "$out"
  '')
