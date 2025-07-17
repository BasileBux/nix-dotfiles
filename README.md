# Nixos config

This is my personal NixOS configuration.

## Installation

To install it, you can use the following commands:

```bash
git clone git@github.com:BasileBux/nix-dotfiles.git nixos
cd nixos
nixos-rebuild switch --flake .#hostname
sudo nixos-rebuild switch --flake /home/basileb/nixos#default --impure
```
