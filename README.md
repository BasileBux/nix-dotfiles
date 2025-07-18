# Nixos config

This is my personal NixOS configuration.

## Installation

To install it, you can use on of the following commands:

```bash
nix-shell -p curl git --run "curl -L https://raw.githubusercontent.com/BasileBux/nix-dotfiles/refs/heads/main/install.sh | sh"
```

or

```bash
git clone git@github.com:BasileBux/nix-dotfiles.git nixos
cd nixos
nixos-rebuild switch --flake .#hostname
sudo nixos-rebuild switch --flake /home/basileb/nixos#default --impure
```
