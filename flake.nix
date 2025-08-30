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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      settings = {
        username = "basileb";
        configPath = "/home/${settings.username}/nixos";
        machine = "asus";
        swapAltSuper = false;
        nixosVersion = "25.05";
      };
      theme =
        import "${settings.configPath}/colors/colors.nix" { inherit settings; };
      colors = theme.theme;
    in {
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs settings colors; };
        modules = [
          "${settings.configPath}/configuration.nix"
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs settings colors; };
          }
        ] ++ nixpkgs.lib.optionals (settings.machine == "asus") [
            # inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402
        ] ++ nixpkgs.lib.optionals (settings.machine == "thinkpad") [
          inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ];
      };
    };
}
