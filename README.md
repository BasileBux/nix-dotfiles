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
  let
    settings = rec {
      username = "";
      configPath = "/home/${username}/nixos";
      machine = "<hostname>";
      desktop = false;
      # Put the version which is in the automatically generated `/etc/nixos/configuration.nix`
      # NEVER CHANGE THIS ONCE YOU SET IT UP !!!
      nixosVersion = ""; 
    };
  in
  {
    inherit settings;
    modules = [
      # Optional additional modules
    ];
  };
};
```

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
