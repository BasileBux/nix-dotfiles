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
    hyprland.url = "github:hyprwm/hyprland";
  };

  outputs =
    { self, nixpkgs, zen-browser, quickshell, home-manager, hyprland }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};


      settings = {
        username = "basileb";
        configPath = "/home/${settings.username}/nixos";
        machine = "asus";
        nixosVersion = "25.05";
      };
      theme = import "${settings.configPath}/colors/colors.nix" { inherit settings; };
      colors = theme.theme;
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs settings colors; };
        modules = [
          "${settings.configPath}/configuration.nix"
          inputs.home-manager.nixosModules.home-manager
          {
            environment.systemPackages =
              [ inputs.quickshell.packages.${system}.default ];
            home-manager.extraSpecialArgs = { inherit inputs settings colors; };
          }
        ];
      };
    };
}
