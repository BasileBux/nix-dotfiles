{ ... }: {
  flake.module.desktop-apps = {
    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        yazi
        thunderbird
        imhex

        # libqalculate provides the `qalc` CLI used by the popup calculator
        # workspace; qalculate-qt is the full GUI. Replaces sage (huge closure).
        libqalculate
        qalculate-qt
      ];
    };
  };
}
