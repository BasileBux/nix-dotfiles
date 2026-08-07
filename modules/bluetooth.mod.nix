{ self, pkgs, ... }: {
  flake.nixosModules.desktop = self.nixosModules.bluetooth;
  flake.nixosModules.bluetooth = { pkgs, ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;

    # Fix MediaTek MT7921 firmware bug: missing completion reports
    # cause A2DP transport disconnection. Disabling USB autosuspend
    # for the BT adapter prevents the chip from going into low-power
    # states that trigger the firmware bug.
    boot.kernelParams = [ "btusb.enable_autosuspend=n" ];

    # Also disable USB autosuspend via udev for the MT7921 BT interface
    services.udev.extraRules = ''
      # MediaTek MT7921 Bluetooth: disable autosuspend to prevent A2DP dropouts
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{idProduct}=="*", TEST=="power/control", ATTR{power/control}="on"
    '';

    environment.systemPackages = with pkgs; [
      blueman
    ];
  };
}
