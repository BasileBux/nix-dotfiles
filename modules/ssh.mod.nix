{
  flake.nixosModules.ssh-server = { ... }: {
    programs.mosh.enable = true;
    services.openssh = {
      enable = true;
      ports = [ 2222 ];
      settings = {
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        ClientAliveInterval = 60;
        ClientAliveCountMax = 3;
        PermitRootLogin = "no";
      };
    };
    programs.ssh.startAgent = true;
  };
}
