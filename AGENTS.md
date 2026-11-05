# NixOS config — agent guide

Personal NixOS flake (flake-parts). Goal: find things fast; dig deeper only when needed.

## Layout

- `flake.nix` — entry point. Auto-imports `*.mod.nix` recursively under `modules/`, `options/`, `hosts/`, and `shells/` only.
- `hosts/<host>/` — one dir per host: `<host>.mod.nix` (defines `flake.nixosConfigurations.<host>` via `lib/mkHost.nix`), `hardware-configuration.nix`, `extra-config.nix` (host-specific overrides), `disko-config.nix` (some hosts), `.age` secret files.
- `modules/` — shared modules. Each defines `flake.module.<name> = { nixos = {...}; home = {...}; }` (either part optional).
- `modules/groups.mod.nix` — profiles: `base` (always on), `personal` (explicit), `desktop` (GUI); `default` aliases `personal`. Hosts opt in via `modules = with inputs.self.flakeModules; [ ... ]`.
- `options/` — global option declarations (`my.settings`, flake-output plumbing).
- `config/` — raw app config files (hypr, nvim, quickshell, slop/pi, vscode), deployed by modules via `xdg.configFile`.
- `packages/` — custom packages. `shells/` — devshells (`perSystem`). `scripts/` — helper scripts referenced by modules. `lib/` — `mkHost.nix` + small lib extension.

## How hosts work

`lib/mkHost.nix` builds each host from its `.mod.nix` file:
- `settings` (`username`, `hostname`, `stateVersion`, optional `homeStateVersion`) → canonical evaluated `config.my.settings` (NixOS), `osConfig.my.settings` (HM). Do not use raw settings module arguments.
- `modules` (unified flakeModules), `nixosModules` (plain NixOS modules/overrides), `ageIdentityPaths` (opt-in secrets decryption).

## Modules

- `.mod.nix` suffix is required (auto-discovery).
- Pattern: options under `my.<name>.*` (a `*-options` module or an options tier), implementation in the enabled module. Options tiers are always imported; functional modules are opt-in per host.
- All `flake.module.*` entries are also exposed as `nixosModules.<name>` / `homeModules.<name>`. Stable keys deduplicate imports. HM halves using `osConfig` require NixOS integration.
- Importing a functional role enables it. Declare shared dependencies with unified `imports`; support/options modules remain inert.
- `lib/inventory.nix` is plain fleet data. `modules/secrets/policy.nix` controls shared-secret recipients and ownership; consumers explicitly request deployment using `my.secrets.requested`.
- Pi and VS Code settings are declarative read-only files; edit repository sources.

## Secrets (agenix)

- `secrets.nix` auto-discovers **every `*.age` file in the repo** and registers them.
- Files under `modules/secrets/env/` become env vars (name derived from path, e.g. `env/api-keys/gemini.age` → `GEMINI_API_KEY`).
- Host secrets live in `hosts/<host>/`; consumed via `age.secrets."hosts/<host>/x.age"` in the host config. Edit with `agenix -e <path>`.

## Build / validate

- `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` or `nixos-rebuild build --flake .#<host>` to check.
- `nix flake check --all-systems --no-build` for all-architecture evaluation; `nix flake check` runs regression fixtures without building system closures.
- You should write minimal comments and only keep them to explain non trivial things, things that you can't understand just by reading the code.
- Hosts: `simon` (desktop), `kamina`, `yoko`, `genome` (server). Edit the host on which you're running, unless told otherwise.
- If you need to have files tracked in git in order for them to get picked up by nix, just run `jj` it will do it. DO NOT USE GIT COMMANDS TO DO THIS.
