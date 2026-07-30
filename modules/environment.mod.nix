{ self, ... }: {
  commonModules.environment = { pkgs, ... }: {
    environment.sessionVariables = {
      SUDO_EDITOR = "nvim";
      EDITOR = "nvim";
    };
    environment.systemPackages = with pkgs; [
      wget
      curl
      openssh
      unzip
      zip
      jq
      btop
      file
    ];
  };
}
