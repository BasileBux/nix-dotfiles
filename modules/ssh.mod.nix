{
  flake.nixosModules.ssh-server = { inputs, config, lib, ... }: {
    imports = [
      ({ ... }: {
        options.my.ssh = lib.mkOption {
          type = lib.types.submodule {
            options.extraAuthorizedKeys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional SSH public keys added to authorized_keys";
            };
          };
          default = { };
          description = "SSH module settings";
        };
      })
    ];

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

    users.users.${config.my.settings.username}.openssh.authorizedKeys.keys =
      inputs.self.keys-admin ++ config.my.ssh.extraAuthorizedKeys;
  };
}
