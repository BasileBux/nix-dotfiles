{
  description = "Main flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zen-browser, quickshell, home-manager }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      username = "basileb";
      configPath = "/home/${username}/nixos";
    in
    {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; inherit username; };
      modules = [
        "${configPath}/configuration.nix"
        inputs.home-manager.nixosModules.home-manager
        {
          environment.systemPackages = [ 
            inputs.zen-browser.packages.${system}.twilight
            inputs.quickshell.packages.${system}.default
          ];
        }
      ];
    };
  };
}
