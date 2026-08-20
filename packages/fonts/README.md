# packages/fonts

Fonts that aren't in nixpkgs or anywhere else are packaged here. They are for personal
use only and are not redistributed. The font packages aren't meant to be used outside
of this config. This package isn't a real package as it's meant to be used in the
font module where we install all the fonts from the catalog (this package).

## Contract

```
packages/fonts/
├── default.nix             # the template: discovery + package builders
├── <Family>/
│   ├── font.nix            # optional metadata
│   ├── *.ttf / *.otf       # regular (free) fonts
│   ├── *.age               # encrypted payload → encrypted (paid) font (auto-detected)
│   └── LICENSE* / OFL*     # license files → installed to $out/share/licenses/<pname>
```

`font.nix` (plain attrset, all optional):

```nix
{
  name = "tx-02";      # attr key + pname (default: directory name)
  version = "1.0";     # default: "0-unstable"
  license = "unfree";  # "ofl" | "cc-by-sa-40" | "unfree" | "unfree-redistributable" | "mit" (missing → throw)
  encrypted = true;    # default: auto-detected from *.age files
  homepage = "...";
  description = "...";
}
```

A font's attribute name is `font.nix.name`, so directories can be renamed freely
without breaking imports. Duplicate names throw.

## How fonts get installed

The fonts module (`modules/fonts.mod.nix`) imports **every** font in the
catalog:

- regular fonts → added to `fonts.packages` (system-wide)
- encrypted fonts → decrypted by agenix at activation, extracted into
  `~/.local/share/fonts/<name>/`, then `fc-cache` is refreshed

The module asserts that hosts have an age identity whenever the catalog
contains encrypted fonts.

If a host only wants a few fonts, skip the module and plumb manually:

```nix
fonts.packages = [
  (pkgs.callPackage ../packages/fonts { }).iosevka-custom
];
```

## Encrypted (paid) fonts

Paid fonts live in the repo as an age-encrypted tarball. They are decrypted at activation,
not at build time.

To add a new paid font, from the repo root (run on a machine with the plaintext
and `age`):

```bash
tar -czf /tmp/tx-02.tar.gz -C /path/to/TX-02 .
age -e -R ~/.ssh/<host>.pub -o packages/fonts/TX-02/tx-02.tar.gz.age /tmp/tx-02.tar.gz
ragenix --rules ./secrets.nix --rekey -i ~/.ssh/<host>
```

## Licensing

| Font | License | file |
|---|---|---|
| IosevkaCustom | SIL OFL 1.1 (`ofl`) | `LICENSE.md` |
| Mx437 DOS/V re. JPN | CC BY-SA 4.0 (`cc-by-sa-40`) | `LICENSE.TXT` (Ultimate Oldschool PC Font Pack by VileR, int10h.org) |
| TX-02 | proprietary, personal use only (`unfree`) | none on purpose — kept inside the encrypted payload |

License files are copied into `$out/share/licenses/<pname>/` on install, so `meta.license`
is always backed by the actual license text.
