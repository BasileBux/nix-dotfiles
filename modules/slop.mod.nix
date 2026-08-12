{ inputs, ... }: {
  flake.module.slop = {
    nixos = { pkgs, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          optmem = inputs.self.packages.${final.stdenv.hostPlatform.system}.optmem;
        })
      ];
      environment.systemPackages = with pkgs; [
        pi-coding-agent
        opencode
        optmem
        inputs.qq.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
