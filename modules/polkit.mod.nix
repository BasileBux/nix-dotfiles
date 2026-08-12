{ ... }: {
  flake.module.polkit = {
    nixos = {
      security.polkit = {
        enable = true;
        enablePkexecWrapper = true;
      };
    };
  };
}
