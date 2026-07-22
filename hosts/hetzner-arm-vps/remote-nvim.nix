{
  pkgs,
  ...
}:

let
  nvimSubdomain = "nvim.asbel.xyz";

  gottyConfigTemplate = ./gotty.hcl;

  caddyWithInfomaniak = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/infomaniak@v1.0.2" ];
    hash = "sha256-4MWGK9iJlF56iiVq4M1nqk54qlcP1ZKi6mgS4+BUw+Y=";
  };
in
{
  imports = [
    ./limits-nvim.nix
  ];

  users.users.nvim = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };
  home-manager.users.nvim = import ./home-nvim.nix;

  system.activationScripts.copyNvimPlugins = ''
    SRC=/home/eugene/.local/share/nvim/site
    DST=/home/nvim/.local/share/nvim/site
    if [ -d "$SRC" ]; then
      mkdir -p "$DST"
      cp -ru "$SRC"/. "$DST"/
      chown -R nvim:users "$DST"
    fi
  '';

  services.openssh.extraConfig = ''
    Match User nvim
      PasswordAuthentication yes
      KbdInteractiveAuthentication yes
      PubkeyAuthentication no
  '';

  services.fail2ban = {
    enable = true;
    maxretry = 10;
    bantime = "1h";

    jails.caddy-auth = ''
      enabled  = true
      filter   = caddy-auth
      logpath  = /var/log/caddy/${nvimSubdomain}.log
      maxretry = 10
      findtime = 10m
      bantime  = 1h
      backend  = auto
    '';
  };

  environment.etc."fail2ban/filter.d/caddy-auth.conf".text = ''
    [Definition]
    failregex = ^.*"remote_ip":"<HOST>".*"status":401.*$
    ignoreregex =
  '';

  services.caddy = {
    enable = true;
    package = caddyWithInfomaniak;

    globalConfig = ''
      acme_dns infomaniak {env.INFOMANIAK_API_TOKEN}
    '';

    virtualHosts.${nvimSubdomain} = {
      logFormat = null;
      extraConfig = ''
        log {
          output file /var/log/caddy/${nvimSubdomain}.log {
            roll_size 10mb
            roll_keep 5
            roll_keep_for 720h
          }
          format json
        }

        basic_auth argon2id {
          {env.GOTTY_USER} {env.GOTTY_PASS_HASH}
        }

        reverse_proxy localhost:8080
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/log/caddy 0750 caddy caddy - -"
  ];

  # INFOMANIAK_API_TOKEN=myToken...
  # GOTTY_USER=user
  # GOTTY_PASS_HASH=hash -> sudo chmod 440 /etc/caddy/creds.env
  systemd.services.caddy.serviceConfig.EnvironmentFile = "/etc/caddy/creds.env";
  # ```
  # caddy hash-password \
  #   --algorithm argon2id \
  #   --argon2id-time 3 \
  #   --argon2id-memory 65536 \
  #   --argon2id-threads 2 \
  #   --argon2id-keylen 32 \
  #   --plaintext "yourpassword"
  # ```

  systemd.services.gotty = {
    description = "GoTTY — share your terminal as a web application";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "nvim";
      Group = "users";
      WorkingDirectory = "/home/nvim";

      ExecStartPre = pkgs.writeShellScript "gotty-gen-config" ''
        set -euo pipefail
        rm -f /home/nvim/.gotty
        cp ${gottyConfigTemplate} /home/nvim/.gotty
      '';

      ExecStart = "${pkgs.gotty}/bin/gotty --config /home/nvim/.gotty ${pkgs.zsh}/bin/zsh";

      Restart = "on-failure";
      RestartSec = "5s";

      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
