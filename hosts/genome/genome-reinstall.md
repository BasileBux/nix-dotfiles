# genome — Raspberry Pi 5 + Argon Neo5 NVMe — Reinstall Guide

This documents exactly how `genome` (a headless NixOS host on a Raspberry Pi 5
with an Argon Neo5 256 GB NVMe) is set up, and how to reproduce it from scratch
*without* re-learning all the trial-and-error. It was written after getting
genome booting via the nvmd firmware-direct (kernelboot) bootloader.

---

## Hardware

- **Board:** Raspberry Pi 5 (aarch64), 8+ GB RAM
- **Case:** Argon NEO 5 (uses the PCIe FFC connector for the NVMe)
- **Disk:** 256 GB NVMe SSD (connected via PCIe) — the boot/root disk
- **Networking:** ethernet (DHCP), headless (no display needed after setup)
- **No SD card needed** — the NVMe is fully self-contained.

> The Pi may fall back to an SD card if present and the NVMe fails to boot;
> for the real target you can leave it out.

---

## The core insight (why the "obvious" path fails)

1. **The NixOS aarch64 ISO never boots on a Pi 5.** It is a generic UEFI ISO
   (`EFI/BOOT/BOOTAA64.EFI` + GRUB) with **no Raspberry Pi firmware**. The Pi 5
   bootloader is **not** UEFI — it needs a FAT partition with `config.txt`,
   `start4.elf`, `fixup4.dat`, etc. So `dd`'ing the ISO is wasted effort.
2. **The stock NixOS aarch64 `sd-image` also lacks Pi 5 support.** It only ships
   `u-boot-rpi3.bin` / `u-boot-rpi4.bin` and `[pi3]`/`[pi4]` config sections —
   no Pi 5 (`kernel_2712.img`, `armstub8-2712.bin`, `bcm2712-rpi-5-b.dtb`).
3. **U-Boot is broken/flaky on this Pi 5.** It loads the splash logo, then hangs
   (no console, no boot) regardless of whether it's booting from a USB stick or
   the NVMe. This is a known Pi 5 + U-Boot problem.
4. **Therefore: use a firmware-direct "kernelboot" bootloader** (no U-Boot).
   The `nvmd/nixos-raspberrypi` flake provides exactly this for the Pi 5
   (`boot.loader.raspberry-pi.bootloader = "kernel"`). The GPU firmware loads
   `kernel.img` + `initrd` + `cmdline.txt` directly from the ESP.

---

## The image that works (and where to get it)

The golden artifact is **nvmd's RPi 5 installer image**, built as a GitHub
Actions artifact:

- **Where:** `https://github.com/nvmd/nixos-raspberrypi/actions/workflows/build-installer-images.yaml`
  → newest successful weekly run → artifact named
  **`nixos-installer-rpi5-kernel.img.zst`**
- **Cadence:** the workflow runs **every Tuesday 00:00 UTC**, artifact retention
  **40 days**. Kernels are also pushed to their cachix on every push, but the
  *installer image closure* is only in the Actions artifact (their cachix.yaml
  pushes the kernel, not the whole installer system).
- **Download requires GitHub auth** (401 anonymously): use `gh` or a token.
  ```bash
  gh auth login   # once
  TOKEN=$(gh auth token)
  curl -L -H "Authorization: Bearer $TOKEN" \
    -o nixos-installer-rpi5-kernel.img.zst \
    "https://api.github.com/repos/nvmd/nixos-raspberrypi/actions/artifacts/<ARTIFACT_ID>/zip"
  ```
  > NOTE: the workflow uses `upload-artifact` with **`archive: false`**, so the
  > downloaded "zip" is *actually the raw `.img.zst`*. Rename it accordingly
  > (don't `unzip`). Verify with `zstd -t` — it decompresses to ~5.2 GB.

  (Get the artifact ID from:
  `curl -s https://api.github.com/repos/nvmd/nixos-raspberrypi/actions/artifacts | jq '.artifacts[] | [.id,.name]'`
  — pick the newest `nixos-installer-rpi5-kernel`.)

- **Why this image**: it's the nvmd RPi 5 installer using the `kernel`
  (generational kernelboot) bootloader, already configured with `dtparam=nvme`.
  It boots the Pi 5 from a USB stick with no U-Boot.

---

## Flash the USB stick

```bash
zstdcat nixos-installer-rpi5-kernel.img.zst | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
```

`/dev/sdX` = the USB stick (verify with `lsblk` first — NEVER the desktop's
system disk). The image's mutable root expands on first boot.

---

## Why we don't use the stock nixos-hardware module directly (and what we do)

The LLM-prepared config originally imported **nixos-hardware**'s
`raspberry-pi-5`, which defaults to `generic-extlinux-compatible` + **U-Boot**.
That U-Boot path **hangs**, so genome was switched to **nvmd's** modules.

In `~/nixos`:

- **`flake.nix`**: added `nixos-raspberrypi` input, **pinned to the exact commit
  the installer artifact was built from** so its kernel/firmware closures are
  cached:
  ```nix
  nixos-raspberrypi = {
    url = "github:nvmd/nixos-raspberrypi/84356fb05fa04cc06df45d479e1e3c6a75540f20";
  };
  ```
  > **Do not** bump this casually — a different rev rebuilds the rpi kernel from
  > source (~2–3 h on the Pi) because its nixpkgs/kernel package differs.
- **`lib/mkHost.nix`**: parameterized `nixosSystem` so genome can use nvmd's lib +
  nixpkgs:
  ```nix
  nixosSystem ? inputs.nixpkgs.lib.nixosSystem,
  ```
- **`hosts/genome/genome.mod.nix`**:
  - replaced the nixos-hardware import with:
    ```nix
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
    ```
  - built via `nixosSystem = inputs.nixos-raspberrypi.lib.nixosSystem;`
  - **secrets-off override** (install-time): `{ age.identityPaths = lib.mkForce []; }`
- **`hosts/genome/extra-config.nix`** — key settings:
  ```nix
  boot.loader.raspberry-pi.bootloader = "kernel";   # firmware-direct, NO u-boot
  hardware.raspberry-pi.config.all.base-dt-params = {
    nvme = { enable = true; };                        # dtparam=nvme (Argon Neo5)
    pciex1_gen = { enable = true; value = 3; };       # dtparam=pciex1_gen=3
  };
  hardware.raspberry-pi.config.all.options.os_check = { enable = true; value = 0; };
  boot.initrd.availableKernelModules = lib.mkForce [ ... nvme pcie_brcmstb rp1 clk-rp1 ... ];
  hardware.deviceTree.enable = lib.mkForce false;
  ```

### Gotchas hit during the build (keep these in mind)

- **`modprobe: FATAL: Module tpm-crb not found`** → nixpkgs' default initrd
  module list includes `tpm-crb`/`tpm-tis` (x86 LUKS/TPM) which the Pi kernel
  doesn't build. Fix: `boot.initrd.availableKernelModules = lib.mkForce [...]`
  (pin the list).
- **nixpkgs' `hardware.deviceTree` default** reads `kernel.buildDTBs`, which the
  nvmd kernel doesn't expose → `hardware.deviceTree.enable = lib.mkForce false;`.
- **`raspberrypi-utils` / `raspberrypi-udev-rules` missing** in our (26.11)
  nixpkgs — but present in nvmd's (26.05). Using nvmd's `lib.nixosSystem` (its own
  nixpkgs) avoids these and aligns with the cached kernel. Don't alias them.
- **`config/pi/settings.json` trailing comma** (written by `pi`) broke `fromJSON`
  in `modules/slop.mod.nix` → every eval failed. Removing the trailing comma fixed
  it; if `pi` re-writes the file with one, strip it again (or make slop tolerant).
- **Never `cp` files with `flake.nix`/`flake.lock`/module files into the wrong
  dir when staging the config** — a stray `genome.mod.nix` at the repo root makes
  flake-parts import it and its `../../lib/mkHost.nix` resolves to `/nix/lib` in
  pure eval. Keep the tree clean.
- **Installer nix is older** than the config needs (`pipe-operators`,
  `nix-command flakes`). On the installer:
  ```bash
  mkdir -p ~/.config/nix && printf 'extra-experimental-features = nix-command flakes pipe-operators\n' > ~/.config/nix/nix.conf
  ```

---

## The age / secrets situation

- genome declares `ageIdentityPaths = [ "/home/basileb/.ssh/genome" ]`.
- The age identity is generated at `~/.ssh/genome` on the desktop (private key
  also copied to the target at `/home/basileb/.ssh/genome` during install).
- **Secrets are disabled** (install-time override `age.identityPaths = mkForce []`)
  because the module `.age` files are encrypted to *other* hosts' keys. Until you
  rekey them with genome's pubkey
  (`age1x5mt2c0f0cqeywcs7m56s9dxhsv5qqxevdmkvvtqxgcafjh65afqa2zrkn`), keep the
  override. genome's own services use manual `/var/lib/genome-secrets/*.env`
  files, so it runs fine without agenix.
- `basileb`'s login password would come from `hosts/genome/password.age` — which
  doesn't exist. Hence **SSH-key-only** auth.

---

## Install procedure (from the installer)

Boot the USB stick (installer). It expands to a NixOS live system, console
login as `nixos`/root. Then (I did this over SSH once the installer was up):

```bash
# Partition the NVMe (wipes it — back up first!)
parted -s /dev/nvme0n1 -- mklabel gpt
parted -s /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
parted -s /dev/nvme0n1 -- set 1 esp on
parted -s /dev/nvme0n1 -- mkpart primary 1GiB 100%
mkfs.fat -F32 -n FIRMWARE /dev/nvme0n1p1
mkfs.ext4 -L NIXOS /dev/nvme0n1p2

# Mount (sd-image style layout)
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/firmware
mount /dev/nvme0n1p1 /mnt/boot/firmware

# Generate hardware config from the TARGET (not the installer)
nixos-generate-config --root /mnt
# -> clean up the spurious duplicate `fileSystems."/"` bind entry it may emit
# -> /mnt/etc/nixos/hardware-configuration.nix

# Ship the fixed flake (scp from desktop) + copy hardware-config into it:
scp -r ~/nixos nixos@<installer-ip>:/root/nixos
# then on the installer:
cp /mnt/etc/nixos/hardware-configuration.nix /root/nixos/hosts/genome/hardware-configuration.nix

# Install (kernel is cached, only initrd/activation rebuild)
nixos-install --flake /root/nixos#genome --no-root-passwd
umount -R /mnt
poweroff
```

Then pull the USB + SD (or leave them; the Pi boots NVMe first), power on.

### Post-install manual fix (the bootloader/es_check gotcha)

The nvmd `kernelboot` builder writes `config.txt` to the ESP with
`os_prefix=nixos/default/` and **omits `os_check=0`** and the DTB from the
os_prefix dir. The Pi 5 bootloader then refuses: it reports
`Device-tree file "nixos/default/bcm2712-rpi-5-b.dtb" not found` and
`The installed OS does not indicate support for Raspberry Pi 5` (because the
on-disk `raspberrypifw` is older than the EEPROM bootloader, and the DTB isn't
where os_prefix expects).

Fix on the ESP (mount `nvme0n1p1`):
```bash
mount /dev/nvme0n1p1 /mnt/boot/firmware   # or /tmp/es
# 1) put the DTB where the firmware looks for it (os_prefix dir)
cp /mnt/boot/firmware/bcm2712-rpi-5-b.dtb /mnt/boot/firmware/nixos/default/
# 2) skip the firmware-version check
sed -i '0,/^\[all\]$/s//[all]\nos_check=0/' /mnt/boot/firmware/config.txt
sync
```

Persist both in the config (so `nixos-rebuild` keeps them):
- `hardware.raspberry-pi.config.all.options.os_check = { enable = true; value = 0; };`
- (`hardware.raspberry-pi.config.all.base-dt-params.nvme` for `dtparam=nvme`.)
- The DTB-in-`nixos/default/` placement is a builder behavior; the reliable
  persistent piece is `os_check=0` (once the check passes the bootloader uses the
  ESP-root DTB). Keep the manual DTB copy as insurance after each generation
  switch, or accept it may need re-copying.

---

## Where the config actually lives

- **Source of truth:** the desktop repo `~/nixos` (git/jj). genome is rebuilt from
  the flake: `nixos-rebuild switch --flake github:BasileBux/nix-dotfiles#genome`
  (or a local checkout).
- **On the Pi:** `/etc/nixos/` only has the minimal generated
  `configuration.nix` + `hardware-configuration.nix` (scaffolding, not the real
  config). The real config is NOT kept on the Pi; it's deployed from the flake.
- **Deployment:** from the desktop, `nixos-rebuild --flake .#genome --target-host ...`
  (and the flake is pushed to git so the Pi can pull it).

---

## Access / sudo

- **SSH:** `ssh -p 2222 basileb@<ip>` — uses your desktop key (injected via
  `inputs.self.keys-admin`). Root login disabled, password auth off.
- **sudo:** `basileb` is in `wheel`, but the default sudoers requires a password
  and basileb has no password (agenix off). Either:
  - **set a password** (boot installer → `nixos-enter --root /mnt` → `passwd basileb`),
    or
  - **make wheel passwordless** in the config:
    `security.sudo.wheelNeedsPassword = false;` (recommended for key-only headless).

---

## Post-install tasks (from `services.nix` comments)

- Tailscale:
  `sudo tailscale up --advertise-tags=tag:raspberrypi --exit-node=ch-zrh-wg-001.mullvad.ts.net --exit-node-allow-lan-access=true`
  > ⚠️ **Do NOT set the exit node by hostname** — Mullvad retires node hostnames
  > (ch-zrh-wg-001 itself died this way, see the 2026-08-27 incident above).
  > Pick a currently-online node from `tailscale exit-node list` instead, or
  > better: `sudo tailscale set --auto-exit-node`.
- Secrets env files at `/var/lib/genome-secrets/<name>.env`
  (vaultwarden, linkwarden, meilisearch, qbittorrent) — see `hosts/genome/services.nix`.
- Media at `/media/jellyfin` owned `1000:1002`.

---

## TL;DR of the whole saga

ISO doesn't boot (no rpi firmware) → stock sd-image has no Pi 5 → U-Boot hangs →
use **nvmd's rpi5 kernelboot installer image** (GitHub artifact, 40-day,
`archive:false` = raw `.img.zst`) → pin nvmd to the artifact commit → swap genome
to `raspberry-pi-5.base` + `bootloader="kernel"` → fix `os_check=0` + DTB on the
ESP → boot. Everything else (initrd tpm, deviceTree, settings.json comma) is
documented above.

---

## Recovery / troubleshooting (real incidents)

### 2026-08-27: Dead Mullvad exit node → SSH "kex_exchange_identification: reset"

**The big one.** genome's Mullvad exit node was configured **by hostname**
(`ch-zrh-wg-001.mullvad.ts.net`, per the post-install task below). Mullvad
retired that node; the tunnel went dead, and genome became intermittently
unreachable over SSH for hours:

```
kex_exchange_identification: read: Connection reset by peer
Connection reset by 100.82.254.103 port 2222
```

**Why it looks like sshd is broken (it isn't):** tailscaled's inbound proxy
accepts the TCP handshake itself (netstack) and only then forwards to the local
service. When the exit-node tunnel is sick, tailscaled's data plane degrades
(its own control connection logged `connection reset by peer`), so new inbound
connections get accepted-then-reset — while ping, established sessions and the
box itself stay perfectly healthy. Easy to misdiagnose as a wedged sshd or
dead machine.

**Fix:** clear or re-select the exit node: `sudo tailscale set --exit-node=`
(or pick a live one from `tailscale exit-node list`). Mullvad rotates/retires
node hostnames constantly (`ch-zrh-wg-001` → `-002`, etc.), so never pin a
hostname — prefer `sudo tailscale set --auto-exit-node` and let Tailscale pick.

**Gotcha — the STATUS column lies for Mullvad nodes:** they are bare WireGuard
endpoints, not full Tailscale peers, so they never answer disco probes:
`tailscale ping` times out, and `exit-node list` flaps between "selected" and
"selected but offline" even when the node works fine. Their peer entries have
zero `lastSeen` and Mullvad WireGuard ports (e.g. `:51820`). Verify with real
traffic (`curl -m 8 https://am.i.mullvad.net/ip`), not the status column.

**Also note (power button):** short-pressing the case power button does
NOTHING: `/proc/device-tree/pwr_button` exists (compatible `gpio-keys`, status
okay) but no gpio-keys/powerkey driver ever binds with the kernelboot DTB, so
the OS never sees the event. Only the firmware's ~5 s hold (hard PMIC cut)
works. Shut down via SSH (`sudo poweroff`) — don't wait on a short press, and
don't misread it as "the machine is wedged".

**Emergency access:** `tailscale-ssh-enable.service` (in
`services/tailscale-serve.nix`) runs `tailscale set --ssh=true` on every boot,
so `tailscale ssh basileb@genome` works even with sshd broken. Requires an
`ssh` grant in the tailnet ACL to actually connect. Also set a password for
basileb (`sudo passwd basileb`) so the physical console is usable — key-only
auth means a monitor + keyboard gets you nothing otherwise.

### fail2ban locking out the admin IP

> This was **suspected** during the 2026-08-27 outage but ruled out — see the
> exit-node incident above for the real cause.

`modules/ssh.mod.nix` enables fail2ban with an SSH jail that bans a source IP
after `maxretry` (10) failed auth attempts. If an agent/script connects with a
wrong user/key (or bad password probes) repeatedly, fail2ban bans the admin's IP
→ even legit key logins from that IP get dropped at the firewall, and the client
reports connection reset / "key exchange refused". This is **by design**, not a bug.

- **Fix:** after the ban expires (`bantime = "24h"`), or manually
  `sudo fail2ban-client unban <IP>`. A reboot clears the in-memory ban list.
- **Prevent:** set `my.ssh.enableFail2ban = false;` per host (genome does this).
  The option is **on by default**; a host can disable it and still keep sshd.
  ```nix
  # in a host module
  my.ssh.enableFail2ban = false;
  ```

### Unclean shutdown → dirty filesystem

A long-press power cut (raw power, not a clean shutdown) leaves ext4 dirty.
Symptoms: SSD won't boot, or hangs. It is **not** data loss — ext4's journal
makes it recoverable. Repair (from the installer, unmounted):

```bash
fsck -fn /dev/nvme0n1p2   # dry-run, inspect
fsck -fy /dev/nvme0n1p2   # repair
```

### Boot partition (ESP) wiped / `/nix/var` missing → won't boot

Worse than a dirty fs: if the ESP (vfat, partition 1) is **empty** and
`/nix/var/nix/profiles` is gone (e.g. a `nixos-rebuild`/cleanup reformatted the
firmware partition, or a bad activation), the Pi firmware has nothing to load
and the SSD won't boot. **Your data is safe** — the system closure is in
`/nix/store`. Recover by reconstructing the profile + ESP from the store:

```bash
G=/nix/store/<hash>-nixos-system-genome-26.05.20260820.5880666  # a real gen
# recreate the system profile (so nixos-enter works)
mkdir -p /mnt/nix/var/nix/profiles /mnt/run
ln -sfn "$G" /mnt/nix/var/nix/profiles/system-4-link
ln -sfn system-4-link /mnt/nix/var/nix/profiles/system
ln -sfn /nix/var/nix/profiles/system /mnt/run/current-system
# nixos-enter needs /etc/NIXOS marker; /etc is a store symlink, so make a real dir
rm -f /mnt/etc; mkdir -p /mnt/etc; touch /mnt/etc/NIXOS
# put the flake on the target and run a switch (repopulates ESP from store)
tar xzf nixos-switch.tar.gz -C /mnt/      # flake at /mnt/nixos
nixos-enter --root /mnt -- nixos-rebuild switch --flake /nixos#genome
```

> **CRITICAL:** the kernelboot builder writes to `cfg.firmwarePath` =
> `/boot/firmware`. During a `nixos-enter` recovery, `/boot/firmware` must be the
> **ESP partition (p1)** — mount it there (`mount /dev/nvme0n1p1 /mnt/boot/firmware`)
> BEFORE the switch. If p1 isn't mounted there, the builder silently writes the
> boot files into a *directory* `/boot/firmware` on the root (p2) and the real
> ESP stays empty → the firmware finds nothing ("Failed to open partition 2").
> If that happens, just copy `p2/boot/firmware/*` onto the ESP:
> ```bash
> mount /dev/nvme0n1p1 /mnt/esp
> cp -a /mnt/boot/firmware/. /mnt/esp/   # from the dir on p2 onto the real ESP
> ```

The kernelboot builder then rewrites `config.txt`, `kernel.img`, `initrd`, DTBs
and the `nixos/<gen>-default/` generations on the ESP. The trailing
"Failed to open dbus connection" during the switch is expected in a chroot (no
running systemd) and harmless — the bootloader is installed regardless.

**Recovery tip:** `nixos-enter` refuses with "is not a NixOS installation" until
`/mnt/etc/NIXOS` exists (it checks `-e $mountPoint/etc/NIXOS`). The marker is
normally a runtime file, not in the store, so recreate it if missing.
