{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.audio;
  flake.nixosModules.audio = { ... }: {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
