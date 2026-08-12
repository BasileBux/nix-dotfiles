{
  flake.module.ssh-server = {
    nixos =
      {
        inputs,
        config,
        lib,
        ...
      }:
      let
        mkSshHost =
          {
            host,
            hostname,
            port ? 22,
            user ? null,
            extra ? "",
          }:
          ''
            Host ${host}
              HostName ${hostname}
              Port ${toString port}
          ''
          + lib.optionalString (user != null) "  User ${user}\n"
          + extra;

        sshHosts = [
          {
            host = "buxtorf-synology";
            hostname = "buxtorf-synology.tail7925e1.ts.net";
            port = 2222;
          }
          {
            host = "kamina";
            hostname = "kamina.tail7925e1.ts.net";
            port = 2222;
          }
          {
            host = "simon";
            hostname = "simon.tail7925e1.ts.net";
            port = 2222;
          }
          {
            host = "yoko";
            hostname = "asbel.xyz";
            port = 2222;
          }
        ];
      in
      {
        imports = [
          {
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
          }
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
        programs.ssh = {
          startAgent = true;
          extraConfig = lib.concatMapStringsSep "\n" mkSshHost sshHosts;
        };

        users.users.${config.my.settings.username}.openssh.authorizedKeys.keys =
          inputs.self.keys-admin ++ config.my.ssh.extraAuthorizedKeys;
      };
  };
}
