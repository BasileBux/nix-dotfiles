# Nixos config

This is my personal NixOS configuration.

## Installation

To install it, you need to create a new host in the `hosts` directory. Do the following:

```bash
nix-shell -p git
git clone https://github.com/BasileBux/nix-dotfiles.git nixos
cd nixos
# Create a new host
mkdir hosts/<hostname>
sudo cp /etc/nixos/hardware-configuration.nix hosts/<hostname>
```

All the following files are standards and should be in the `hosts/<hostname>` directory:
```bash
.
├── default.nix # Put whatever you want in there to be machine specific
├── hardware-configuration.nix
└── hypr
    ├── config.lua
    └── host.lua
```
Note: the `hypr` directory is optional and only makes sense if you are on a desktop.

In `flake.nix` add a new host in `systems` which should look like:
```nix
<hostname> =
  {
    settings = {
      username = "";        # required
      machine = "<hostname>"; # required
      nixosVersion = "";    # required, from `/etc/nixos/configuration.nix` NEVER CHANGE THIS ONCE YOU SET IT UP !!!
      desktop = false;      # optional, defaults to false
      configPath = "/home/${username}/nixos"; # optional, defaults to /home/<username>/nixos
    };
    modules = [
      # Optional additional modules
    ];
  };
```

`flake.nix` validates the `settings` attrset with a submodule: missing required fields or unknown fields will fail the rebuild with a clear error.

And then rebuilt the system with:
```bash
sudo nixos-rebuild switch --flake /home/basileb/nixos#<hostname> --impure
```

For certain things, you might need a `secrets.nix` file in the root of the repo:

```secrets.nix
{
  keys = {
    anthropicApiKey = "";
    openaiApiKey = "";
    geminiApiKey = "";
    googleGenerativeAiApiKey = "";
    moonshotApiKey = "";
    tavilyApiKey = "";
    xaiApiKey = "";
    nvidiaApiKey = "";
  };
  github-token = "";
  rad-passphrase = "";
}
```
