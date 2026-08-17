# Neovim config

This config only works with neovim 0.12+, but the old version is still available
in the, now archived, [neovim-config](https://github.com/BasileBux/neovim-config) repo
under the `legacy` tag which corresponds to commit `d9d652732810eb91aee98a38d2061ceefcda9241`.

## Nix

This config is managed by home manager which makes the vim pack lock file readonly
in `~/.config/nvim/nvim-pack-lock.json` and the path is hard coded in neovim. To
update the plugins, you need to run the following commands:
```bash
XDG_CONFIG_HOME=/tmp nvim -u ~/nixos/config/nvim/init.lua
# In neovim `:lua vim.pack.update()` and then `:wq` once everything is done
mv /tmp/nvim-pack-lock.json ~/nixos/config/nvim/nvim-pack-lock.json
```
