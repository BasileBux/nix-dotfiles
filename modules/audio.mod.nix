{ ... }: {
  flake.module.audio = {
    nixos = { pkgs, ... }: {
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        # Bluetooth audio tuning for MediaTek MT7921 stability:
        # - Increase buffer for SBC to reduce underruns
        # - Enable AAC for better quality/stability if supported
        # - Faster reconnect on transport failure
        wireplumber.configPackages = [
          (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
            bluez_monitor.properties = {
              ["bluez5.enable-sbc-xq"] = true,
              ["bluez5.enable-msbc"] = true,
              ["bluez5.enable-hw-volume"] = true,
              ["bluez5.headset-roles"] = "[ a2dp_sink ]",
              ["bluez5.codecs"] = "[ sbc sbc_xq aac ]",
              ["bluez5.auto-connect"] = true,
            }
          '')
        ];
      };

      environment.systemPackages = with pkgs; [
        pavucontrol
      ];
    };
  };
}
