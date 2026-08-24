{
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
    {
      host = "genome";
      hostname = "genome.tail7925e1.ts.net";
      port = 2222;
    }
  ];
in
{
  flake.module.ssh-client = {
    nixos = { pkgs, ... }: {
      programs.ssh = {
        startAgent = true;
        extraConfig = lib.concatMapStringsSep "\n" mkSshHost sshHosts;
      };
      environment.systemPackages = [
        pkgs.mosh
      ];
    };
  };

  flake.module.ssh-server = {
    nixos =
      {
        inputs,
        config,
        lib,
        ...
      }:
      {
        imports = [
          {
            options.my.ssh = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  # fail2ban protects SSH from brute force; on by default, but a
                  # host can disable it (e.g. headless/key-only boxes where a
                  # misbehaving agent might get the admin IP banned and lock
                  # everyone out). sshd stays enabled regardless.
                  enableFail2ban = lib.mkOption {
                    type = lib.types.bool;
                    default = true;
                    description = "Whether to enable fail2ban (SSH jails)";
                  };
                  extraAuthorizedKeys = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [ ];
                    description = "Additional SSH public keys added to authorized_keys";
                  };
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

        users.users.${config.my.settings.username}.openssh.authorizedKeys.keys =
          inputs.self.keys-admin ++ config.my.ssh.extraAuthorizedKeys;

        # fail2ban SSH jail. See my.ssh.enableFail2ban (on by default).
        services.fail2ban = lib.mkIf config.my.ssh.enableFail2ban {
          enable = true;
          maxretry = 10;
          bantime = "24h";
        };
      };
  };
}
