{ self, pkgs, ... }: {
  flake.nixosModules.desktop = self.nixosModules.audio;
  flake.nixosModules.audio = {pkgs, ... }: {
    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
