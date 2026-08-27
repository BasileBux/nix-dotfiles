## NixOS system

This machine runs NixOS. Here is what you need to know:

- **System configuration** lives at `~/nixos/`. That is where the main `flake.nix` and related files are.
- **Hosts** are defined in `~/nixos/hosts/`. Each time I mention a host (e.g., `kamina`, `simon`, `yoko`), I am referring to a host defined in that directory. When asked to edit a config, always edit the config on the current host, unless explicitly asked to edit another host.
- **Simon** host is the desktop machine used to manage all the other machines. If you are running on the simon host, you can, if explicitly allowed, access any other host in the tailnet via `ssh <host>`.
- **Paths are not standard FHS**: binaries are under `/run/current-system/sw/bin/`, not `/usr/bin`. Do not assume `/bin/bash` — always use `/usr/bin/env` if you need it (it is patched), or better, call programs by name and rely on `PATH`.
- **Missing software**: if a program you need is not found, you can use `nix-shell -p <package>` to temporarily get it. Example: `nix-shell -p ffmpeg --run "ffmpeg -version"`.
- **Only use `nix-shell -p` when the user explicitly says "use nixpkgs" or "use nix-shell" in their prompt.** Otherwise, report what is missing and ask.
- **Always `eval` the nix code**: if you are explicitly asked to write some nix config, always run some evaluation command to check if what you wrote is actually correct and works. However, you should add flags like `--no-build` to not do the changes on the system and let the user do that.
- **Do not try `apt`, `pip`, `npm install -g`, or `sudo make install`.** They will not work as you expect.

## VCS

Never use version control systems if not explicitly asked to. If you absolutely need to use one but wasn't asked to, ask the user first.

I always use jujutsu (`jj`) when available but there always is git as a fallback. When you want to make changes to a repository, you should always check if it is a jujutsu repo first. If it is, use `jj` commands. If not, use `git` commands.
