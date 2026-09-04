{ pkgs, lib, ... }:
{
  # Access is SSH-key only (port 2222, root login off, password auth off) and
  # the machine isn't exposed to the internet, so skip the sudo password.
  security.sudo.wheelNeedsPassword = false;

  home-manager.users.basileb.home.enableNixpkgsReleaseCheck = false;

  boot = {
    kernelParams = [
      "console=serial0,115200n8"

      # 2026-09-04: adding `crashkernel=32M@0x3FE000000` + `ramoops.*` params
      # (pstore/ramoops crash logging, reserved last-32MiB-of-RAM region)
      # made the box hard-hang in EARLY KERNEL, before any console output and
      # long before userspace (no journal entries from the failed boots;
      # kernel/initrd/DTB on the ESP were byte-identical to the known-good
      # generation, so the cmdline was the only delta). Removing the params
      # fixed boot. Do NOT re-add without testing each param individually on
      # the ESP cmdline.txt (boot hangs = power cycle + edit from installer).
      # Suspects: crashkernel reservation interacting with the firmware's
      # `numa=fake=8` memory layout, and/or ramoops memremap of the top-of-RAM
      # region on BCM2712. Needs investigation with a serial console attached.
      # "crashkernel=32M@0x3FE000000"
      # "ramoops.mem_address=0x3FE000000"
      # "ramoops.mem_size=0x2000000"
      # "ramoops.record_size=0x1000"
      # "ramoops.console_size=0x100000"
      # "ramoops.pmsg_size=0x10000"
      # "ramoops.max_reason=2"
    ];

    # nixpkgs' default initrd module list includes tpm-crb/tpm-tis (x86 LUKS
    # TPM support) which the Raspberry Pi kernel doesn't build, breaking the
    # initrd build with "modprobe: FATAL: Module tpm-crb not found". Pin the
    # list to what the Pi 5 actually has (nvmd's raspberry-pi-5.base also sets
    # some of these; mkForce keeps the whole list deterministic).
    initrd.availableKernelModules = lib.mkForce [
      "nvme"
      "usb_storage"
      "usbhid"
      "xhci_pci"
      "vc4"
      "pcie_brcmstb"
      "clk-rp1"
      "rp1"
      "reset-raspberrypi"
      "mmc_block"
      "ext4"
      "sd_mod"
    ];

    loader.raspberry-pi = {
      # Firmware-direct kernel boot: no U-Boot (U-Boot hangs on Pi 5).
      bootloader = "kernel";
    };
  };

  # nvmd's modules reference raspberrypi-utils / raspberrypi-udev-rules, which
  # exist in nixos-raspberrypi's own nixpkgs (genome builds against it via
  # nixos-raspberrypi.lib.nixosSystem).

  # DEVICE TREES: nvmd's kernelboot builder installs the board DTB into the
  # os_prefix generation dir automatically (useGenerationDeviceTree=true). Do
  # NOT set hardware.deviceTree.enable — nixpkgs' module wants kernel.buildDTBs
  # (which nvmd's kernel lacks) and disabling it also prevents the DTB from
  # being placed in nixos/default/, making the boot go black.

  # Enable the NVMe on the external PCIe connector (Argon NEO 5).
  # dtparam=nvme is handled by the GPU firmware's built-in overlay engine.
  hardware.raspberry-pi.config.all.base-dt-params = {
    nvme = { enable = true; }; # -> dtparam=nvme
    # Gen 3 is out of spec for the Pi 5 PCIe link and the NVMe already threw a
    # controller timeout+reset under load (2026-09-01), then the box hard-hung
    # silently under heavy torrent I/O (2026-09-04). Downgraded to the
    # in-spec Gen 2 — still ~2x faster than the SSD needs for this workload.
    pciex1_gen = { enable = true; value = 2; }; # -> dtparam=pciex1_gen=2
  };

  # The bootloader's os_check refuses to boot if the on-disk firmware
  # (raspberrypifw) is older than the EEPROM bootloader. Skip it. (The DTB is
  # expected at ESP root; the bootloader falls back to it once os_check passes.)
  hardware.raspberry-pi.config.all.options.os_check = {
    enable = true;
    value = 0;
  };

  # Raspberry Pi firmware/board tooling
  # - rpi-eeprom-update: bootloader/EEPROM firmware updates (stored on the
  #   board's SPI flash, independent of what NixOS boots from)
  # - vcgencmd: temperature/throttling/clock inspection
  # - nvme-cli/jq: SMART health inspection (nvme-health timer below)
  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
    nvme-cli
    jq
  ];

  # USERSPACE WATCHDOG: the BCM2835/BCM2712 hardware watchdog is built into
  # this kernel (CONFIG_BCM2835_WDT=y, /dev/watchdog exists). Arm it via
  # systemd: PID 1 pings every runtimeTime/2 while alive, so a hard kernel
  # hang (e.g. the silent 2026-09-04 NVMe/PCIe freeze) triggers an automatic
  # reboot after runtimeTime instead of waiting for a manual power cycle.
  # During shutdown/reboot the timeout is raised to rebootTime (default 10min).
  systemd.settings.Manager = {
    WatchdogDevice = "/dev/watchdog";
    RuntimeWatchdogSec = "30s";
  };

  # Mount pstore so crash records from ramoops show up in /sys/fs/pstore
  # (and get archived to /var/lib/systemd/pstore by systemd-pstore.service).
  systemd.mounts = [
    {
      what = "pstore";
      where = "/sys/fs/pstore";
      type = "pstore";
    }
  ];

  # DAILY NVMe SMART HEALTH CHECK: genome has form here — an NVMe controller
  # timeout+reset on 2026-09-01 and a suspected silent NVMe/PCIe hang on
  # 2026-09-04. Log the full SMART page to the journal daily and fail the
  # unit (visible in `systemctl list-timers` / monitoring) if the drive
  # reports critical warnings, media errors, or a depleted spare area.
  systemd.services.nvme-health = {
    description = "NVMe SMART health check";
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Only log on failure so the journal stays quiet when healthy.
      SyslogIdentifier = "nvme-health";
    };
    script =
      let
        nvme = "${pkgs.nvme-cli}/bin/nvme";
        jq = "${pkgs.jq}/bin/jq";
      in
      ''
        SMART=$(${nvme} smart-log --output-format=json /dev/nvme0)
        get() { ${jq} -r ".$1 // 0" <<< "$SMART"; }

        CRIT=$(get critical_warning)
        MEDIA=$(get media_errors)
        SPARE=$(get available_spare)
        THRESH=$(get available_spare_threshold)
        USED=$(get percent_used)
        TEMP=$(get temperature)   # Kelvin in nvme-cli JSON
        TEMP_C=$(( (TEMP - 273) ))

        echo "nvme0 health: critical_warning=$CRIT media_errors=$MEDIA available_spare=$SPARE/$THRESH percent_used=$USED temp=$TEMP_C C"

        # Values may be JSON strings; force integer comparison.
        if [ "$((CRIT))" -ne 0 ]; then echo "NVMe CRITICAL WARNING: $CRIT" >&2; exit 1; fi
        if [ "$((MEDIA))" -ne 0 ]; then echo "NVMe MEDIA ERRORS: $MEDIA" >&2; exit 1; fi
        # Only compare when the drive actually reports a spare threshold (this
        # one reports 0/0).
        if [ "$((THRESH))" -gt 0 ] && [ "$((SPARE))" -lt "$((THRESH))" ]; then
          echo "NVMe spare area below threshold" >&2; exit 1
        fi
      '';
  };

  systemd.timers.nvme-health = {
    description = "Daily NVMe SMART health check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      OnUnitActiveSec = "1d";
      Persistent = true;
    };
  };
}
