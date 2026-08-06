{
  pkgs,
  ...
}:

let
  nvimSubdomain = "nvim.asbel.xyz";
  dufsSubpath = "/files";

  gottyConfigTemplate = ./gotty.hcl;
  gottyIndexTemplate = ./gotty-index.html;
  dufsIndexTemplate = ./dufs-index.html;

  # Combine custom index.html with default dufs assets (index.js, index.css, favicon.ico)
  # When --assets is used, dufs completely overrides built-in assets and looks for all
  # files on disk. Without this, __ASSETS_PREFIX__ references like index.js would 404.
  dufsAssets = pkgs.runCommand "dufs-assets" { } ''
    mkdir -p $out
    cp ${dufsIndexTemplate} $out/index.html
    cp ${pkgs.dufs.src}/assets/index.js $out/index.js
    cp ${pkgs.dufs.src}/assets/index.css $out/index.css
    cp ${pkgs.dufs.src}/assets/favicon.ico $out/favicon.ico
  '';

  caddyWithInfomaniak = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/infomaniak@v1.0.2" ];
    hash = "sha256-xoOWamsUcKclhw6WVchg/LlBZiDlArA8M/axxpo0Wlg=";
  };
in
{
  imports = [
    ./limits-nvim.nix
  ];

  users.users.nvim = {
    isNormalUser = true;
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
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

        basic_auth /* argon2id {
          {env.GOTTY_USER} {env.GOTTY_PASS_HASH}
        }

        handle ${dufsSubpath}/* {
          reverse_proxy localhost:8081
        }

        handle {
          reverse_proxy localhost:8080
        }
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

      ExecStartPre = "${pkgs.writeShellScript "gotty-copy-index" ''
        rm -f /home/nvim/.gotty-index.html
        cp ${gottyIndexTemplate} /home/nvim/.gotty-index.html
      ''}";

      ExecStart = "${pkgs.gotty}/bin/gotty --config ${gottyConfigTemplate} ${pkgs.zsh}/bin/zsh";

      Restart = "on-failure";
      RestartSec = "5s";

      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };

  systemd.services.dufs = {
    description = "DuFS — static file server";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "nvim";
      Group = "users";
      WorkingDirectory = "/home/nvim";

      ExecStartPre = "${pkgs.writeShellScript "dufs-copy-assets" ''
        rm -rf /home/nvim/.dufs-assets
        cp -r ${dufsAssets} /home/nvim/.dufs-assets
        chmod -R u+w /home/nvim/.dufs-assets
      ''}";

      ExecStart = "${pkgs.dufs}/bin/dufs --bind 127.0.0.1 --port 8081 --path-prefix ${dufsSubpath} --assets /home/nvim/.dufs-assets --hidden '.*' --allow-all";

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
