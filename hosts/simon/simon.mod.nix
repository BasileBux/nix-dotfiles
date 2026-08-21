{
  lib,
  inputs,
  ...
}:
let
  hyprland-config = {
    monitors = [
      {
        description = "Thermotrex Corporation TL140ADXP01";
        mode = "2560x1600@60.00Hz";
        scale = "1.6";
        builtin = true;
        mirror = {
          mode = "1920x1080@120.00Hz";
          scale = "1";
        };
      }
      {
        description = "ASUSTek COMPUTER INC VG27WQ M1LMDW019052";
        mode = "2560x1440@165.00Hz";
        scale = "1";
      }
    ];
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
      hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("kitty kitten ssh kamina"))
    '';
  };
  quickshell-config = {
    powerProfiles = {
      setCommand = [
        "asusctl"
        "profile"
        "set"
      ];
      profiles = [
        "Quiet"
        "Balanced"
        "Performance"
      ];
      getterCommand = [ "asusctl-profile-get" ];
    };
  };
  nushell-config = {
    accentColor = "#fb8b1e";
    extraConfig = /* nu */ ''
      alias vpn = sh ($env.HOME)/nixos/scripts/tailscale-exit-nodes.sh

      def --env config [] { cd ($env.HOME)/nixos; nvim flake.nix }
      def --env nvimconfig [] { cd ($env.HOME)/nixos/config/nvim; nvim init.lua }
      def --env qsconfig [] { cd ($env.HOME)/nixos/config/quickshell; nvim shell.qml }
      def --env hlconfig [] { cd ($env.HOME)/nixos/config/hypr; nvim hyprland.lua }

      # Wake or shut down kamina (raspberry pi) through upsnap
      def kamina [action: string] {
          print $action
          if $action != "on" and $action != "off" and $action != "reboot" {
              print "Wrong action, usage: kamina on/off/reboot"
              return
          }

          let url = "https://upsnap.tail7925e1.ts.net"
          let email = "bazil.bux@gmail.com"
          # Decrypted by agenix on this host, readable via the age.secrets override below
          let password = (open /run/agenix/hosts/simon/kamina-upsnap-password.age | str trim)

          let auth = (
              http post $"($url)/api/collections/_superusers/auth-with-password"
                  {identity: $email, password: $password}
                  --content-type application/json
          )
          let token = $auth.token

          let devices = (
              http get $"($url)/api/collections/devices/records?perPage=200"
                  --headers [Authorization $"Bearer ($token)"]
          )

          let id = ($devices.items | where name == "Kamina" | first | get id)

          if $action == "on" {
              http get $"($url)/api/upsnap/wake/($id)" --headers [Authorization $"Bearer ($token)"] --allow-errors
          }
          if $action == "off" {
              http get $"($url)/api/upsnap/shutdown/($id)" --headers [Authorization $"Bearer ($token)"] --allow-errors
          }
          if $action == "reboot" {
              http get $"($url)/api/upsnap/reboot/($id)" --headers [Authorization $"Bearer ($token)"] --allow-errors
          }
      }
    '';
  };
in
{
  flake.nixosConfigurations.simon = (import ../../lib/mkHost.nix { inherit inputs lib; }) rec {

    settings = {
      username = "basileb";
      hostname = "simon";
      nixosVersion = "25.05";
      gitName = "BasileBux";
      gitEmail = "basile.buxtorf@ik.me";
    };
    system = "x86_64-linux";
    ageIdentityPaths = [ "/home/${settings.username}/.ssh/${settings.hostname}" ];

    modules = with inputs.self.flakeModules; [
      desktop
      smb
      tailscale
      slop
      radicle
    ];

    nixosModules = [
      ./extra-config.nix
      {
        my.hyprland = hyprland-config;
        my.nushell = nushell-config;
        my.quickshell = quickshell-config;
        my.smb = {
          host = "100.86.179.75";
          destination = "/home";
          mountPoint = "/home/${settings.username}/synology";
        };
      }
      {
        age.secrets."hosts/simon/kamina-upsnap-password.age" = {
          owner = settings.username;
          group = "users";
          mode = "0400";
        };
      }
      inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
    ];
  };
}
