{ settings, inputs, ... }: {
  imports = [ inputs.self.homeModules.default ];

  home.username = "nvim";
  home.homeDirectory = "/home/nvim";
  home.stateVersion = "${settings.nixosVersion}";
  home.enableNixpkgsReleaseCheck = false;
}
