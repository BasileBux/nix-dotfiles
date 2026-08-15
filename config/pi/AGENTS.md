## NixOS system

This machine runs NixOS. Here is what you need to know:

- **System configuration** lives at `~/nixos/`. That is where the main `flake.nix` and related files are.
- **Paths are not standard FHS**: binaries are under `/run/current-system/sw/bin/`, not `/usr/bin`. Do not assume `/bin/bash` — always use `/usr/bin/env` if you need it (it is patched), or better, call programs by name and rely on `PATH`.
- **Missing software**: if a program you need is not found, you can use `nix-shell -p <package>` to temporarily get it. Example: `nix-shell -p ffmpeg --run "ffmpeg -version"`.
- **Only use `nix-shell -p` when the user explicitly says "use nixpkgs" or "use nix-shell" in their prompt.** Otherwise, report what is missing and ask.
- **Always `eval` the nix code**: if you are explicitly asked to write some nix config, always run some evaluation command to check if what you wrote is actually correct and works. However, you should add flags like `--no-build` to not do the changes on the system and let the user do that.
- **Do not try `apt`, `pip`, `npm install -g`, or `sudo make install`.** They will not work as you expect.

## Memory

Your memory is OptMem:
- The tool is `/run/current-system/sw/bin/memo`
- Your memories are in `~/.optmem/memory`

OptMem outlives every session, compaction, model and vendor change.
Without it you do not know who you are, or what was decided and tried.

### At startup: activating OptMem (mandatory)

Run `/run/current-system/sw/bin/memo wake` before any other tool call, in every session, and
then do exactly what it prints, to the end of its output.

### While working: register memories (mandatory)

Call `/run/current-system/sw/bin/memo note "<1 line, max 280 chars>"` whenever you learn
something new, or something worth keeping happens. That covers a task
worth real effort, a fact or insight the user teaches you, anything you
learn about their life (even indirectly), any event of lasting effect.

Do not register redundant memories.

If `/run/current-system/sw/bin/memo note` asks a compression: do it before your next action.

Never edit or delete anything under `~/.optmem/memory`: the tool manages it.

### When you need an old memory: search, or navigate

`/run/current-system/sw/bin/memo recall <regex>` searches every memory, word for word.

Your memories also form a binary tree: #0-1, #2-3 ... exist as one-line
summaries, pairs of those as #0-3, and so on -- every `#a-b` line wake
prints is one node of it. `/run/current-system/sw/bin/memo zoom <a-b>` opens a node into its
two halves, down to the raw memories.

### If you're a subagent: skip everything above

Parallel sessions on this machine are all you, and may all write memories.
A subagent is not: it must never run `memo`, because it cannot judge what
is already known, and its notes would arrive duplicated and incorrectly.
When you spawn one, write: `You are a subagent. Don't run memo.`
