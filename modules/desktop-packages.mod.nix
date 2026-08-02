{ self, inputs, ... }: {
  flake.nixosModules.desktop = self.nixosModules.desktop-packages;
  flake.nixosModules.desktop-packages =
    {
      config,
      pkgs,
      inputs,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          optmem = inputs.self.packages.${final.stdenv.hostPlatform.system}.optmem;
        })
        (final: prev: {
          sage = prev.sage.override { requireSageTests = false; };
        })
      ];

      users.users.${config.my.settings.username}.extraGroups = [
        "kvm"
        "dialout"
      ];

      environment.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        NIXOS_OZONE_WL = "1";
      };

      environment.systemPackages = with pkgs; [
        wl-clipboard
        appimage-run
        libva
        libGL
        ffmpeg-full
        openh264
        nemo
        kdePackages.gwenview
        evince
        mpv
        zenity
        blueman
        pavucontrol
        yazi
        typst
        ghidra-bin
        steam
        gnome-calculator
        pinta
        thunderbird
        jellyfin-desktop
        imhex
        vlc
        opencode
        pi-coding-agent
        radicle-node
        radicle-desktop
        optmem
      ];
    };
}
