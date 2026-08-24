{ pkgs, lib, ... }:
{
  # Access is SSH-key only (port 2222, root login off, password auth off) and
  # the machine isn't exposed to the internet, so skip the sudo password.
  security.sudo.wheelNeedsPassword = false;

  home-manager.users.basileb.home.enableNixpkgsReleaseCheck = false;

  boot = {
    kernelParams = [ "console=serial0,115200n8" ];

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
    pciex1_gen = { enable = true; value = 3; }; # -> dtparam=pciex1_gen=3
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
  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
  ];
}
