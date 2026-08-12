{ ... }: {
  flake.module.desktop-apps = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        yazi
        thunderbird
        imhex
      ];
    };
  };
}
