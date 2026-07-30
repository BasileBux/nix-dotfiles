# Migration plan: dendritic `.mod.nix` with flake-parts

This plan restructures the NixOS configuration to use:
- **flake-parts** as the flake framework
- **`.mod.nix` auto-discovery** — every `.mod.nix` file in the repo is automatically imported, no manual import lists
- **Self-registering modules** — each file registers its own outputs into `flake.nixosModules.*` and `flake.homeModules.*`
- **Options-driven per-host config** — host differences are NixOS option values set in the host file, not separate data files

Adapted from the [NCC](https://github.com/RGBCube/ncc) pattern. (Note: the ncc repo is also cloned in ~/tmp/ncc for easier access)

---

## Final directory tree

```
~/nixos/
├── flake.nix                       # Thin: inputs + flake-parts + listFilesRecursive auto-discovery
├── flake.lock
├── lib/
│   ├── default.nix                 # Extends nixpkgs lib, auto-imports lib/*.nix
│   └── mkHost.nix                  # Thin factory: hostName → nixosSystem
├── options/
│   ├── flake-outputs.mod.nix       # Defines flake.nixosModules, .homeModules, commonModules
│   └── settings.mod.nix            # settingsModule: validates username, desktop, accentColor, etc.
├── modules/                        # All auto-discovered .mod.nix files (flat)
│   │
│   │  ═══ Core (always-on, every host) ═══
│   ├── core.mod.nix                # networking.hostName, timezone, system.stateVersion
│   ├── users.mod.nix               # users.users + home-manager wiring + shell assignment
│   ├── nix.mod.nix                 # nix.settings, experimental-features, gc, registry
│   ├── environment.mod.nix         # sessionVariables (EDITOR, SUDO_EDITOR), base systemPackages
│   ├── localisation.mod.nix        # console font, xkb layout (us,ch fr)
│   ├── security.mod.nix            # rtkit, sudo config, pam sshd
│   ├── ssh.mod.nix                 # NixOS: openssh server, mosh, ssh agent.  Home: none (client is implicit)
│   ├── tailscale.mod.nix           # services.tailscale
│   │
│   │  ═══ Profiles (opt-in) ═══
│   ├── common.mod.nix              # Dev toolchain packages (gcc, rust, go, node, lua, python, etc.)
│   ├── smb.mod.nix                 # cifs-utils + synology mount
│   │
│   │  ═══ Desktop (tag: flake.nixosModules.desktop) ═══
│   ├── audio.mod.nix               # pipewire (NixOS)
│   ├── bluetooth.mod.nix           # bluetooth + blueman (NixOS)
│   ├── hyprland.mod.nix            # Hyprland + hypridle (NixOS + home-manager).  Lua config generated from options!
│   ├── plymouth.mod.nix            # boot splash
│   ├── polkit.mod.nix              # polkit + pkexec wrapper
│   ├── fonts.mod.nix               # font packages (NixOS)
│   ├── libvirtd.mod.nix            # libvirtd + virt-manager (NixOS)
│   ├── appimage.mod.nix            # appimage support (NixOS)
│   ├── desktop-packages.mod.nix    # Desktop-only systemPackages (nemo, mpv, steam, wireshark, etc.)
│   ├── upower.mod.nix              # upower service (NixOS)
│   ├── gvfs.mod.nix                # automount (NixOS)
│   │
│   │  ═══ Home-manager modules (tag: flake.homeModules.*) ═══
│   ├── git.mod.nix                 # git + jujutsu (home)
│   ├── nh.mod.nix                  # nh clean (home)
│   ├── zsh.mod.nix                 # zsh + aliases + API keys (home)
│   ├── tmux.mod.nix                # tmux (home)
│   ├── neovim.mod.nix              # neovim + LSP + formatters (home)
│   ├── ghostty.mod.nix             # ghostty (home)
│   ├── browser.mod.nix             # zen-browser or helium (home)
│   ├── fastfetch.mod.nix           # fastfetch (home)
│   ├── quickshell.mod.nix          # quickshell (home)
│   ├── vscode.mod.nix              # vscode (home)
│   ├── kitty.mod.nix               # kitty (home)
│   ├── mime-apps.mod.nix           # mime-apps (home)
│   ├── nemo.mod.nix                # nemo dconf (home)
│   └── theming.mod.nix             # GTK/Qt theming, xdg portal (home)
│   │
│   │  ═══ Host-specific hardware modules ═══
│   ├── asus-g14.mod.nix            # asusctl, supergfxd, rocm, nix-ld, kernel params
│   └── hetzner.mod.nix             # boot.grub, networking, fonts
│
├── hosts/
│   ├── asus-g14/
│   │   ├── asus-g14.mod.nix        # Thin host: mkHost call + option values
│   │   └── hardware-configuration.nix
│   └── hetzner-arm-vps/
│       ├── hetzner-arm-vps.mod.nix # Thin host: mkHost call + option values
│       ├── hardware-configuration.nix
│       └── disko-config.nix
│
├── packages/
│   └── optmem.mod.nix              # perSystem.packages.optmem
│
├── shells/
│   ├── python.mod.nix              # perSystem.devShells.python
│   └── android.mod.nix             # perSystem.devShells.android
│
├── dotfiles/                       # Non-nix assets: Lua, images, wallpapers, misc config
│   ├── hypr/                       # Shared Hyprland Lua modules
│   │   ├── hyprland.lua
│   │   ├── hypridle.nix → moves to modules/hyprland.mod.nix (NixOS side)
│   │   └── lua/                    # general.lua, input.lua, keybinds.lua, monitors.lua, rules.lua, settings.lua, startup.lua
│   ├── nvim/                       # Neovim config (referenced by modules/neovim.mod.nix)
│   ├── quickshell/                 # Quickshell config (referenced by modules/quickshell.mod.nix)
│   ├── zsh/                        # zsh theme, initContent (referenced by modules/zsh.mod.nix)
│   ├── fastfetch/                  # Sasaki-Kojiro.jpg
│   ├── fonts/                      # IosevkaCustom build
│   ├── vscode/                     # settings.json, keybindings.json
│   └── misc/                       # ghostty-cursor-warp.glsl, etc.
│
└── secrets.nix                     # Unchanged for now
```

---

## How `.mod.nix` auto-discovery works

`flake.nix` becomes:

```nix
{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    # ... all other inputs unchanged ...
  };

  outputs = inputs:
    (import "${inputs.flake-parts}/lib.nix" {
      lib = import ./lib inputs.nixpkgs.lib;
    }).mkFlake
      { inherit inputs; }
      ({ lib, ... }: {
        systems = [ "x86_64-linux" "aarch64-linux" ];
        imports =
          lib.filesystem.listFilesRecursive ./.
          |> builtins.filter (lib.strings.hasSuffix ".mod.nix");
      });
}
```

Every file ending in `.mod.nix` **anywhere** in the repo is automatically a flake-parts module.
Add a new concern → drop a file.  No import lists anywhere.

---

## The glue: `options/flake-outputs.mod.nix`

Defines the module namespaces that `.mod.nix` files register into:

```nix
{ config, lib, ... }: {
  options.flake.nixosModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };
  options.commonModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  # commonModules are automatically part of nixosModules
  config.flake.nixosModules = lib.mkMerge [
    config.commonModules
  ];
}
```

### How module registration works

Flake-parts uses `mkMerge` on `lazyAttrsOf`. When two modules both set `flake.nixosModules.default`, they **merge** into a combined module rather than conflicting. This is how the "default" profile gets built up from many files:

```nix
# modules/ssh.mod.nix:
{ self, ... }: {
  flake.nixosModules.default = self.nixosModules.ssh-server;
}

# modules/nix.mod.nix:
{ self, ... }: {
  flake.nixosModules.default = self.nixosModules.nix;
}
# → config.flake.nixosModules.default = mkMerge [ ssh-server nix ]
```

### Profile tags

Desktop-only modules tag themselves under a profile key. Multiple modules can contribute to the same profile:

```nix
# modules/hyprland.mod.nix:
{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.hyprland;
}

# modules/audio.mod.nix:
{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.audio;
}
# → config.flake.nixosModules.desktop = mkMerge [ hyprland audio ]
```

Hosts then import the profile: `extraModules = [ self.nixosModules.desktop self.nixosModules.common ]`.

---

### `commonModules` vs `flake.nixosModules`

| Namespace | Purpose | Imported by |
|-----------|---------|-------------|
| `commonModules.*` | Internal modules shared across NixOS and potentially other systems. Automatically merged into `flake.nixosModules`. | Every host (via `default` merge) |
| `flake.nixosModules.*` | Public NixOS modules. Hosts import specific keys. | Hosts that opt in |
| `flake.homeModules.*` | Home-manager modules. Wired by `users.mod.nix`. | All hosts (via user wiring) |

---

## `lib/mkHost.nix` — thin factory

Replaces the current `lib/mkSystem.nix`.  Settings validation moves to `options/settings.mod.nix`.

```nix
{ inputs, lib }:
{
  hostName,
  system ? "x86_64-linux",
  settings,
  extraModules ? [ ],
}:
let
  secretsPath = "${settings.configPath}/secrets.nix";
  secrets = if builtins.pathExists secretsPath then import secretsPath else { };
  hardwarePath = ../hosts/${hostName}/hardware-configuration.nix;
  globals = { browser = "helium"; };
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs settings secrets globals; };
  modules =
    [
      inputs.self.nixosModules.default       # everything tagged "default"
      inputs.self.nixosModules.home-manager  # the home-manager wiring
      {
        networking.hostName = settings.hostname;
        system.stateVersion = settings.nixosVersion;
        my.settings = settings;              # also available via module system
      }
    ]
    ++ extraModules
    ++ lib.optional (builtins.pathExists hardwarePath) hardwarePath;
}
```

---

## `modules/users.mod.nix` — home-manager wiring

This is where NixOS and home-manager meet.  All home-manager modules are imported for every user.
Desktop-only home modules use `lib.mkIf` internally on `config.my.settings.desktop`.

```nix
{ self, inputs, lib, ... }:     # ← flake-parts scope, captures self & inputs
let
  allHomeModules = builtins.attrValues self.homeModules;
  mkUser = settings: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager.useGlobalPkgs = true;
    home-manager.extraSpecialArgs = { inherit inputs settings lib; };
    home-manager.users.${settings.username}.imports = allHomeModules;
  };
in
{
  commonModules.users = { settings, ... }: {
    imports = [ (mkUser settings) ];

    users.users.${settings.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = "zsh";
    };

    programs.zsh.enable = true;
  };

  flake.nixosModules.home-manager = self.nixosModules.users;
}
```

Desktop-only home modules become self-guarding:

```nix
# modules/ghostty.mod.nix:
{ lib, ... }: {
  flake.homeModules.ghostty = { config, ... }: {
    config = lib.mkIf config.my.settings.desktop {
      programs.ghostty = { ... };
    };
  };
}
```

This way **all** home modules are imported for **all** hosts, but desktop-specific ones no-op on servers.

---

## The options-driven pattern: example `modules/hyprland.mod.nix`

This is the most important transformation.  Currently Hyprland has:
- `dotfiles/hypr/hyprland.nix` — the Nix module
- `dotfiles/hypr/hyprland.lua` — shared Lua entry point
- `dotfiles/hypr/lua/*.lua` — shared Lua modules (monitors, keybinds, rules, etc.)
- `hosts/asus-g14/hypr/config.lua` — **host-specific** (monitor specs, brightness devices, startup commands, mainMod)
- `hosts/asus-g14/hypr/host.lua` — **host-specific** (extra keybinds, custom Lua)

In the new pattern, the host-specific files **disappear**.  Everything becomes NixOS options that the host file sets as values.  The module generates Lua at build time.

```nix
{ self, config, lib, pkgs, ... }:
let
  inherit (lib.types) str int either listOf submodule lines;
  inherit (lib.options) mkOption;

  monitorType = submodule {
    options = {
      description = mkOption { type = str; description = "Monitor description string for Hyprland matching."; };
      mode = mkOption { type = str; example = "2560x1600@60.00Hz"; };
      position = mkOption { type = str; default = "0x0"; };
      scale = mkOption { type = either str int; default = "1"; };
    };
  };
in
{
  # ── Options ──────────────────────────────────────────────────
  options.my.hyprland = {
    monitors.primary = mkOption {
      type = monitorType;
      description = "Primary (built-in) monitor.  REQUIRED — rebuild fails if unset.";
    };
    monitors.secondary = mkOption {
      type = monitorType;
      description = "Secondary (external) monitor.  REQUIRED — rebuild fails if unset.";
    };
    monitors.mirror = {
      mode = mkOption {
        type = str;
        default = "1920x1080@120.00Hz";
        description = "Mode to use when mirroring to external displays.";
      };
      scale = mkOption { type = either str int; default = "1"; };
    };
    brightness.monitor = mkOption {
      type = str;
      example = "amdgpu_bl2";
      description = "Backlight device name for brightnessctl.  REQUIRED on desktop.";
    };
    brightness.keyboard = mkOption {
      type = str;
      example = "asus::kbd_backlight";
      description = "Keyboard backlight device name.  REQUIRED on desktop.";
    };
    startup = mkOption {
      type = listOf str;
      default = [ ];
      example = [ "asusctl -c 80" "asusctl profile set Quiet" ];
      description = "Extra commands to run on Hyprland startup.";
    };
    mainMod = mkOption {
      type = str;
      default = "SUPER";
      description = "Main modifier key (SUPER or ALT).";
    };
    hostLua = mkOption {
      type = lines;
      default = "";
      description = "Arbitrary Lua injected into host.lua for host-specific bindings or logic.";
    };
  };

  # ── Profile tag ─────────────────────────────────────────────
  flake.nixosModules.desktop = self.nixosModules.hyprland;

  # ── NixOS side ───────────────────────────────────────────────
  flake.nixosModules.hyprland =
    { inputs, pkgs, ... }:
    {
      boot.plymouth.enable = true;
      boot.consoleLogLevel = 0;
      boot.initrd.verbose = false;
      boot.kernelParams = [ "quiet" "splash" "loglevel=3" "udev.log_priority=3" ];

      programs.hyprland.enable = true;
      programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      nix.settings.substituters = [ "https://hyprland.cachix.org" ];
      nix.settings.trusted-substituters = [ "https://hyprland.cachix.org" ];
      nix.settings.trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        NIXOS_OZONE_WL = "1";
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprctl dispatch global quickshell:lock-screen";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            { timeout = 180; on-timeout = "hyprctl dispatch dpms off"; on-resume = "hyprctl dispatch dpms on"; }
            { timeout = 240; on-timeout = "loginctl lock-session"; }
            { timeout = 600; on-timeout = "systemctl hybrid-sleep"; }
          ];
        };
      };
    };

  # ── Home side ────────────────────────────────────────────────
  flake.homeModules.hyprland =
    { config, pkgs, ... }:
    let
      cfg = config.my.hyprland;

      # Generate config.lua from the options
      configLua = pkgs.writeText "hypr-config.lua" /* lua */ ''
        return {
          monitors = {
            primary = {
              description = "${cfg.monitors.primary.description}",
              mode = "${cfg.monitors.primary.mode}",
              position = "${cfg.monitors.primary.position}",
              scale = ${builtins.toString cfg.monitors.primary.scale},
            },
            secondary = {
              description = "${cfg.monitors.secondary.description}",
              mode = "${cfg.monitors.secondary.mode}",
              position = "${cfg.monitors.secondary.position}",
              scale = ${builtins.toString cfg.monitors.secondary.scale},
            },
            mirror = {
              mode = "${cfg.monitors.mirror.mode}",
              scale = ${builtins.toString cfg.monitors.mirror.scale},
            },
          },
          brightness = {
            monitor = "${cfg.brightness.monitor}",
            keyboard = "${cfg.brightness.keyboard}",
          },
          startup = ${builtins.toJSON cfg.startup},
          mainMod = "${cfg.mainMod}",
        }
      '';

      # host.lua from the hostLua option (empty string = empty file, harmless)
      hostLua = pkgs.writeText "hypr-host.lua" cfg.hostLua;
    in
    {
      home.packages = with pkgs; [
        bibata-cursors hyprcursor playerctl grim slurp brightnessctl
      ];

      home.sessionVariables.HYPRLAND_STUBS =
        "${inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland}/share/hypr/stubs";

      # Shared files (unchanged, symlinked from dotfiles/)
      xdg.configFile."hypr/hyprland.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${builtins.toString ../dotfiles/hypr}/hyprland.lua";
      xdg.configFile."hypr/lua".source =
        config.lib.file.mkOutOfStoreSymlink "${builtins.toString ../dotfiles/hypr}/lua";

      # Generated files (no host-specific directories!)
      xdg.configFile."hypr/config.lua".source = configLua;
      xdg.configFile."hypr/host.lua".source = hostLua;

      home.activation.reloadHyprland = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        if ${pkgs.procps}/bin/pgrep -x "Hyprland" > /dev/null 2>&1; then
          ${pkgs.hyprland}/bin/hyprctl reload
        fi
      '';
    };
}
```

Then `hosts/asus-g14/asus-g14.mod.nix` becomes:

```nix
{ lib, inputs, ... }:
{
  imports = lib.singleton (import ../../lib/mkHost.nix {
    inherit inputs lib;
    hostName = "asus-g14";
    settings = {
      username = "basileb";
      machine = "asus-g14";
      hostname = "laptop-asus";
      desktop = true;
      accentColor = "#fb8b1e";
      nixosVersion = "25.05";
      configPath = "/home/basileb/nixos";
    };
    extraModules = [
      inputs.self.nixosModules.desktop
      inputs.self.nixosModules.common
      inputs.self.nixosModules.asus-g14
      inputs.self.nixosModules.smb
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
    ];
  });

  # ── Host-specific option values ──────────────────────────────
  # These MUST be set — rebuild fails without them.

  my.hyprland = {
    monitors.primary = {
      description = "Thermotrex Corporation TL140ADXP01";
      mode = "2560x1600@60.00Hz";
      position = "0x0";
      scale = "1.6";
    };
    monitors.secondary = {
      description = "ASUSTek COMPUTER INC VG27WQ M1LMDW019052";
      mode = "2560x1440@165.00Hz";
      position = "1600x0";
      scale = "1";
    };
    monitors.mirror.mode = "1920x1080@120.00Hz";
    brightness.monitor = "amdgpu_bl2";
    brightness.keyboard = "asus::kbd_backlight";
    startup = [
      "asusctl -c 80"
      "asusctl profile set Quiet"
    ];

    # Formerly hosts/asus-g14/hypr/host.lua:
    hostLua = /* lua */ ''
      local config = require("config")
      local mainMod = config.mainMod
      hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("nvtop -s > /dev/null"))
    '';
  };
}
```

The `hosts/asus-g14/hypr/` directory vanishes entirely.  What was a file on disk is now a Nix option value.

---

## Required-option enforcement (crash the rebuild)

Options that are declared as `type = str;` (no default) and `type = submodule { ... };` (no default) will cause a module evaluation error if the host doesn't set them.  No extra work needed — the module system handles it.

**These will crash the rebuild if not set on a desktop host:**

| Option | Module |
|--------|--------|
| `my.hyprland.monitors.primary` | `hyprland.mod.nix` |
| `my.hyprland.monitors.secondary` | `hyprland.mod.nix` |
| `my.hyprland.brightness.monitor` | `hyprland.mod.nix` |
| `my.hyprland.brightness.keyboard` | `hyprland.mod.nix` |

If you later add a desktop host, you'll be forced to provide these values at rebuild time — no silent "defaults that break at runtime."

---

## Module-by-module migration map

### Core (always on, every host)

| Current location | New `modules/*.mod.nix` | Registers as | Notes |
|---|---|---|---|
| `hosts/default.nix` (networking.hostName) | `core.mod.nix` | `commonModules.core` | hostname, timezone, stateVersion |
| `hosts/default.nix` (users) | `users.mod.nix` | `commonModules.users` | user creation + home-manager wiring |
| `hosts/default.nix` (nix settings) | `nix.mod.nix` | `flake.nixosModules.default` | nix.settings, gc, registry |
| `hosts/default.nix` (sessionVariables, base packages) | `environment.mod.nix` | `commonModules.environment` | EDITOR, SUDO_EDITOR + wget, curl, git, etc. |
| `hosts/default.nix` (console, xkb) | `localisation.mod.nix` | `commonModules.localisation` | console font, xkb layout |
| `hosts/default.nix` (rtkit, sudo, pam) | `security.mod.nix` | `commonModules.security` | rtkit, sudo pwfeedback, pam sshd |
| `hosts/default.nix` (openssh, mosh, ssh agent) | `ssh.mod.nix` | `flake.nixosModules.default` | openssh, mosh, ssh agent |
| `hosts/default.nix` (tailscale) | `tailscale.mod.nix` | `commonModules.tailscale` | tailscale |
| `hosts/default.nix` (programs.zsh) | `users.mod.nix` | (already in users) | `programs.zsh.enable = true` |

### Profiles (opt-in)

| Current location | New `modules/*.mod.nix` | Registers as | Notes |
|---|---|---|---|
| `hosts/profiles/common.nix` | `common.mod.nix` | `flake.nixosModules.common` | dev toolchain packages |
| `hosts/profiles/smb.nix` | `smb.mod.nix` | `flake.nixosModules.smb` | cifs-utils + synology mount |

### Desktop (opt-in, tagged under `flake.nixosModules.desktop`)

| Current location | New `modules/*.mod.nix` | Registers as | Notes |
|---|---|---|---|
| `hosts/profiles/desktop.nix` (pipewire) | `audio.mod.nix` | `desktop` | pipewire + alsa |
| `hosts/profiles/desktop.nix` (bluetooth) | `bluetooth.mod.nix` | `desktop` | bluetooth + blueman |
| `hosts/profiles/desktop.nix` (hyprland) | `hyprland.mod.nix` | `desktop` | NixOS + home.  **Options-driven Lua generation.** |
| `dotfiles/hypr/hypridle.nix` | absorbed into `hyprland.mod.nix` | — | hypridle is part of the hyprland NixOS module |
| `hosts/profiles/desktop.nix` (plymouth) | `plymouth.mod.nix` | `desktop` | also absorbed into hyprland if preferred |
| `hosts/profiles/desktop.nix` (polkit) | `polkit.mod.nix` | `desktop` | polkit + pkexec |
| `hosts/profiles/desktop.nix` (fonts) | `fonts.mod.nix` | `desktop` | font packages |
| `hosts/profiles/desktop.nix` (libvirtd) | `libvirtd.mod.nix` | `desktop` | libvirtd + virt-manager |
| `hosts/profiles/desktop.nix` (appimage) | `appimage.mod.nix` | `desktop` | appimage support |
| `hosts/profiles/desktop.nix` (packages) | `desktop-packages.mod.nix` | `desktop` | nemo, mpv, steam, wireshark, etc. |
| `hosts/profiles/desktop.nix` (upower) | `upower.mod.nix` | `desktop` | upower service |
| `hosts/profiles/desktop.nix` (gvfs) | `gvfs.mod.nix` | `desktop` | automount |

### Home-manager modules (tagged under `flake.homeModules.*`)

| Current location | New `modules/*.mod.nix` | Registers as | Notes |
|---|---|---|---|
| `home.nix` (git + jujutsu) | `git.mod.nix` | `flake.homeModules.git` | git + jujutsu |
| `home.nix` (nh) | `nh.mod.nix` | `flake.homeModules.nh` | nh clean |
| `dotfiles/zsh/zsh.nix` + `dotfiles/zsh/alias.nix` | `zsh.mod.nix` | `flake.homeModules.zsh` | zsh + aliases + API keys |
| `dotfiles/tmux.nix` | `tmux.mod.nix` | `flake.homeModules.tmux` | tmux |
| `dotfiles/neovim.nix` | `neovim.mod.nix` | `flake.homeModules.neovim` | neovim + LSP + formatters |
| `dotfiles/ghostty.nix` | `ghostty.mod.nix` | `flake.homeModules.ghostty` | ghostty. Desktop-only via `mkIf`. |
| `dotfiles/zen.nix` | `browser.mod.nix` | `flake.homeModules.browser` | zen-browser or helium. Desktop-only. |
| `dotfiles/fastfetch/fastfetch.nix` | `fastfetch.mod.nix` | `flake.homeModules.fastfetch` | fastfetch. Desktop-only. |
| `dotfiles/quickshell.nix` | `quickshell.mod.nix` | `flake.homeModules.quickshell` | quickshell. Desktop-only. |
| `dotfiles/vscode.nix` | `vscode.mod.nix` | `flake.homeModules.vscode` | vscode. Desktop-only. |
| `dotfiles/kitty.nix` | `kitty.mod.nix` | `flake.homeModules.kitty` | kitty. Desktop-only. |
| `dotfiles/mime-apps.nix` | `mime-apps.mod.nix` | `flake.homeModules.mime-apps` | mime-apps. Desktop-only. |
| `dotfiles/nemo.nix` | `nemo.mod.nix` | `flake.homeModules.nemo` | nemo dconf. Desktop-only. |
| `dotfiles/theming.nix` | `theming.mod.nix` | `flake.homeModules.theming` | GTK/Qt theming, xdg portal. Desktop-only. |

### Host-specific (in `modules/`)

| Current location | New `modules/*.mod.nix` | Registers as | Notes |
|---|---|---|---|
| `hosts/asus-g14/default.nix` (asusctl, supergfxd, rocm, nix-ld, kernel) | `asus-g14.mod.nix` | `flake.nixosModules.asus-g14` | asus-specific hardware |
| `hosts/hetzner-arm-vps/default.nix` (boot, networking) | `hetzner.mod.nix` | `flake.nixosModules.hetzner` | hetzner-specific |

### Packages & shells

| Current location | New location | Registers as |
|---|---|---|
| `pkgs/default.nix` + `pkgs/optmem/` | `packages/optmem.mod.nix` | `perSystem.packages.optmem` |
| `shells/python/flake.nix` | `shells/python.mod.nix` | `perSystem.devShells.python` |
| `shells/android/flake.nix` | `shells/android.mod.nix` | `perSystem.devShells.android` |

### What stays in `dotfiles/`

These are **non-nix data files** that modules reference by path. They don't need `.mod.nix` files:

- `dotfiles/hypr/hyprland.lua` — shared Lua entry point
- `dotfiles/hypr/lua/*.lua` — shared Lua modules
- `dotfiles/nvim/` — Neovim config (lua, ftplugin, plugins)
- `dotfiles/quickshell/` — Quickshell QML config
- `dotfiles/zsh/basileb.zsh-theme` — zsh theme template
- `dotfiles/zsh/initContent.zsh` — zsh init content
- `dotfiles/fastfetch/Sasaki-Kojiro.jpg` — fastfetch logo
- `dotfiles/fonts/IosevkaCustom/` — custom font source
- `dotfiles/vscode/settings.json`, `keybindings.json` — vscode config
- `dotfiles/misc/ghostty-cursor-warp.glsl` — ghostty shader

---

## How an individual module looks

### Simple module (no options needed): `modules/tailscale.mod.nix`

```nix
{ self, ... }: {
  commonModules.tailscale = { ... }: {
    services.tailscale.enable = true;
  };
}
```

### Module with options: `modules/browser.mod.nix`

```nix
{ self, lib, ... }: {
  options.my.browser = lib.mkOption {
    type = lib.types.enum [ "helium" "zen-twilight" ];
    default = "helium";
    description = "Which browser to use.";
  };

  flake.homeModules.browser = { config, inputs, ... }: {
    config = lib.mkIf config.my.settings.desktop {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = config.my.browser == "zen-twilight";
      home.sessionVariables.WEB_BROWSER = config.my.browser;
      # helium is in desktop-packages.mod.nix
    };
  };
}
```

### Co-located NixOS + home: `modules/ssh.mod.nix`

```nix
{ self, ... }: {
  flake.nixosModules.default = self.nixosModules.ssh-server;

  flake.nixosModules.ssh-server = { ... }: {
    programs.mosh.enable = true;
    services.openssh = {
      enable = true;
      ports = [ 2222 ];
      settings = {
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
      };
    };
    programs.ssh.startAgent = true;
  };
}
```

No home-module counterpart needed — ssh client config is implicit (the agent + the openssh package comes from `environment.systemPackages`).

---

## Migration phases

Each phase ends with `sudo nixos-rebuild switch` on both hosts to confirm nothing broke.

### Phase 1: Bootstrap flake-parts (smallest change, highest confidence)

1. Add `flake-parts` input to `flake.nix`
2. Create `lib/default.nix` — extends nixpkgs lib, auto-imports `lib/*.nix`
3. Wrap current `outputs` in `mkFlake` with `listFilesRecursive` auto-discovery
4. Keep existing `systems` map and `mkSystem.nix` working — just move them under `flake.nixosConfigurations`
5. Rebuild both hosts

**Files changed:** `flake.nix`, `flake.lock`, new `lib/default.nix`

### Phase 2: Create glue + thin hosts

1. Create `options/flake-outputs.mod.nix`
2. Create `options/settings.mod.nix` (extract from `lib/mkSystem.nix`)
3. Create `lib/mkHost.nix` (thin factory)
4. Rewrite `hosts/asus-g14/asus-g14.mod.nix` (thin, calls `mkHost`)
5. Rewrite `hosts/hetzner-arm-vps/hetzner-arm-vps.mod.nix`
6. Remove old `hosts/asus-g14/default.nix`, `hosts/hetzner-arm-vps/default.nix`
7. Rebuild both hosts

**Files changed:** new `options/`, new `lib/mkHost.nix`, new host `.mod.nix` files, deletion of old host files

### Phase 3: Extract modules one at a time

For each module in the migration map:
1. Create the `.mod.nix` file in `modules/`
2. Remove the corresponding config from `hosts/default.nix` or `home.nix`
3. Rebuild

Order: do the non-desktop core modules first (they affect both hosts), then desktop modules (asus-g14 only).

### Phase 4: Hyprland options-driven rewrite

1. Create `modules/hyprland.mod.nix` with full options + Lua generation
2. Update `hosts/asus-g14/asus-g14.mod.nix` with option values
3. Remove `hosts/asus-g14/hypr/` directory
4. Rebuild asus-g14

### Phase 5: Packages, shells, cleanup

1. Move `pkgs/optmem` → `packages/optmem.mod.nix`
2. Move shells → `shells/*.mod.nix`
3. Delete `home.nix`, `hosts/default.nix`, `hosts/profiles/`, old `lib/mkSystem.nix`
4. Final rebuild on both hosts
