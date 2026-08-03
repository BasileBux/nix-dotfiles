{ lib, inputs, ... }:
let
  hyprland-config = {
    monitors = {
      primary = {
        description = "Thermotrex Corporation TL140ADXP01";
        mode = "2560x1600@60.00Hz";
        position = "0x0";
        scale = "1.6";
        mirror = {
          mode = "1920x1080@120.00Hz";
          scale = "1";
        };
      };
      secondary = {
        description = "ASUSTek COMPUTER INC VG27WQ M1LMDW019052";
        mode = "2560x1440@165.00Hz";
        position = "1600x0";
        scale = "1";
      };
    };
    brightness = {
      monitor = "amdgpu_bl2";
      keyboard = "asus::kbd_backlight";
    };
    startup = [
      "asusctl -c 80"
      "asusctl profile set Quiet"
    ];
    mainMod = "SUPER";
    extraConfig = /* lua */ ''
      local mainMod = require("config").mainMod
      hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("nvtop -s > /dev/null"))
    '';
  };
in
{
  flake.nixosConfigurations.asus-g14 = (import ../../lib/mkHost.nix { inherit inputs lib; }) {
    hostName = "asus-g14";
    homeModules = [
      inputs.self.homeModules.desktop
    ];
    settings = {
      username = "basileb";
      hostname = "asus-g14";
      accentColor = "#fb8b1e";
      nixosVersion = "25.05";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
      extraShellAliases = {
        config = "cd $HOME/nixos && nvim flake.nix";
        nvimconfig = "cd $HOME/nixos/dotfiles/nvim && nvim init.lua";
        qsconfig = "cd $HOME/nixos/dotfiles/quickshell && nvim shell.qml";
        hlconfig = "cd $HOME/nixos/dotfiles/hypr && nvim hyprland.lua";
        vpn = "$HOME/nixos/scripts/tailscale-exit-nodes.sh";
      };
    };
    extraModules = [
      ./extra-config.nix
      { my.hyprland = hyprland-config; }
      inputs.self.nixosModules.desktop
      inputs.self.nixosModules.smb
      inputs.self.nixosModules.tailscale
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
    ];
  };
}
