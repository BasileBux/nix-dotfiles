# NixOS configuration

Personal NixOS flake using flake-parts and unified NixOS/Home Manager modules.

## Structure

- `hosts/<host>/<host>.mod.nix`: host construction and profile/role selection.
- `modules/`: unified feature modules and profiles.
- `options/`: flake schemas, module plumbing, regression checks.
- `lib/mkHost.nix`: host construction, Home Manager integration, required hardware file.
- `lib/inventory.nix`: plain fleet data, also consumed by secret tooling.
- `modules/secrets/policy.nix`: explicit shared-secret recipients and ownership.
- `config/`: application configuration deployed by feature modules.
- `packages/`, `shells/`, `scripts/`: custom packages, development environments, helpers.

Only `*.mod.nix` files under `modules`, `options`, `hosts`, and `shells` are automatically imported.

## Module contract

A unified module bundles `nixos`, `home`, and `imports`. Select modules through
`self.flakeModules`; `nixosModules` and `homeModules` export their individual halves.
Stable identities deduplicate dependencies shared by several profiles/features.

- Selecting a functional module enables its advertised role. An optional `enable`
  switch defaults to true and can disable a role inherited through an aggregate.
- Options/support modules are inert. `libvirtd` is a compatibility support module;
  select `libvirt-host`, `libvirt-client`, or `libvirt-router` for functionality.
- Declare unified dependencies in `imports`. Runtime dependencies must be imported
  or checked with actionable assertions; registering a tailnet service requires Tailscale.
- `config.my.settings` is canonical. Home Manager consumers use
  `osConfig.my.settings`; raw `settings` is not a module argument.
- Home Manager exports that use `osConfig` require NixOS integration and their
  corresponding NixOS configuration. They are not standalone Home Manager modules.
- Use upstream NixOS/Home Manager options directly unless a wrapper expresses
  actual personal policy, integration, or useful validation.

Profiles:

- `base`: system defaults, Nix, user, security, SSH client, XDG, shared schemas/secrets.
  Automatically supplied by `mkHost`.
- `personal`: base plus tools, VCS, Nushell, and the full editor/toolchain environment.
- `desktop`: graphical features. Select alongside `personal` on a workstation.
- `default`: compatibility alias for `personal`.

All existing hosts explicitly retain their personal environment. NetworkManager,
keyboard and firmware policy now live in `system-defaults`, not `nix`.

## Add a host

Create `hosts/<hostname>/<hostname>.mod.nix` and copy its hardware configuration to
`hosts/<hostname>/hardware-configuration.nix`. The hardware file is required.

```nix
{ lib, inputs, ... }: {
  flake.nixosConfigurations.example =
    (import ../../lib/mkHost.nix { inherit inputs lib; }) {
      system = "x86_64-linux";
      settings = {
        username = "john";
        hostname = "example";
        stateVersion = "26.05";
        # homeStateVersion defaults to stateVersion; git identity has defaults.
        gitName = "John Doe";
        gitEmail = "john@example.com";
      };
      modules = with inputs.self.flakeModules; [ personal ssh-server ];
      nixosModules = [ ./extra-config.nix ];
      # Optional: provision this key independently before activating secrets.
      # ageIdentityPaths = [ "/home/john/.ssh/example" ];
    };
}
```

`stateVersion` and `homeStateVersion` are compatibility settings, **not the running
release**. Do not bump them when updating nixpkgs. Existing values were preserved.
Hardware-specific overrides belong in host-local files. Add inventory entries when
using fleet services, and explicit secret policy before requesting shared secrets.

## Secrets

`secrets.nix` discovers age files. Host secrets are encrypted for their host and
admin keys and registered only on that host. Shared module/font secrets must have
an entry in `modules/secrets/policy.nix`, specifying authorized host recipients and
runtime ownership (`root`, a service user, or `primary-user`).

Enabled consumers request shared secrets through `my.secrets.requested`. A secret
is deployed only when requested, authorized by policy, and identities are configured.
Nushell/Zsh request their environment secrets; SMB requests its credentials; fonts
request encrypted payloads. Adding an env file also requires adding its policy.

Keyless hosts skip optional encrypted fonts and SMB mounts. Required credentials
for enabled services produce assertions. Configured identity paths do not prove
that keys exist or can decrypt the ciphertext. Host secrets still require identities.

Recipient policy does **not** retroactively modify ciphertext. After reviewing a
policy change, rekey with an authorized identity:

```sh
ragenix --rules ./secrets.nix --rekey -i ~/.ssh/simon
```

No ciphertext was changed during the structural migration. In particular SMB and
paid-font recipients are now narrower in policy; rekeying is required to enforce
that cryptographically. Admin access is retained by design.

## Application settings

Application configuration is declarative and normally linked read-only from the
Nix store, including Pi and VS Code settings. Change repository files and rebuild;
application UI changes are not the source of truth. Runtime state remains writable.

**VS Code migration:** if previously copied settings/keybindings exist, back them
up and remove/move those files before activating their new managed symlinks.
Home Manager may otherwise refuse to overwrite them. Do not discard unreviewed edits.

Jellyfin's `my.services.jellyfin.upstreamPort` is the *assumed existing listener*
used by the proxy, not a listener configuration option. Change Jellyfin networking
separately and keep this value in sync. The default remains 8096.

Tailscale integration owns this node's Serve configuration and advertised-route
list. Applying the configuration resets Serve and reapplies the registry, including
when empty. Stop actions clear owned state when removing these applying units.
Do not manage competing Serve entries manually.

## Validate

```sh
# Evaluate every output, including both architectures, without building systems:
nix flake check --all-systems --no-build

# Run the checks on this machine (host checks only evaluate system derivations):
nix flake check

# Evaluate one full system without building or deploying it:
nix eval .#nixosConfigurations.simon.config.system.build.toplevel.drvPath

# Formatting:
nix fmt
```

Checks cover host evaluation, settings defaults/overrides, disabled-service cleanup,
required-secret assertions, snapshot gating, keyless consumers, empty Tailscale
state, module deduplication, and generated Lua/Nushell syntax and value round trips. Syntax checks build only their fixtures/tools, not a system closure.

Activate deliberately, after reviewing changes:

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

## Credits

The unified-module structure was inspired by [RGBCube's ncc](https://github.com/RGBCube/ncc/tree/dentride)
(MIT licensed). Secret discovery and shell configuration also derive from ncc,
with subsequent adaptations. This repository is MIT licensed.
