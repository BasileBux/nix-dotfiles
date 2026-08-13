{ ... }: {
  flake.module.desktop-apps = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        yazi
        thunderbird
        imhex

        sage # For the popup calculator
      ];
    };
  };
}
