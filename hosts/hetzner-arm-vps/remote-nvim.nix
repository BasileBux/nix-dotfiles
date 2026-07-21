{
  pkgs,
  lib,
  settings,
  ...
}:

let
  nvimSubdomain = "nvim.asbel.xyz";

  gottyConfigTemplate = ./gotty.hcl;

  caddyWithInfomaniak = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/infomaniak@v1.0.2" ];
    hash = lib.fakeHash;
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

  # Might use caddy basic auth (https://caddyserver.com/docs/caddyfile/directives/basic_auth)
  # instead of gotty's own auth. Or even both at the same time.
  services.caddy = {
    enable = true;
    package = caddyWithInfomaniak;

    globalConfig = ''
      acme_dns infomaniak {env.INFOMANIAK_API_TOKEN}
    '';

    virtualHosts.${nvimSubdomain} = {
      extraConfig = ''
        respond "GoTTY will be here soon — TLS is working! 🎉"

        # TODO: once gotty is tested and enabled, replace the line above with:
        # reverse_proxy localhost:8080
      '';
    };
  };

  # Caddy reads the Infomaniak API token from this file.
  # Create it manually (keeps the token out of /nix/store):
  #
  #   echo 'INFOMANIAK_API_TOKEN=...' | sudo tee /etc/caddy/infomaniak.env
  #   sudo chown root:caddy /etc/caddy/infomaniak.env
  #   sudo chmod 440 /etc/caddy/infomaniak.env
  systemd.services.caddy.serviceConfig.EnvironmentFile = "/etc/caddy/infomaniak.env";

  # Before enabling, create the credentials file (kept OUT of /nix/store):
  #
  #   echo 'username:password' > /home/eugene/.gotty-creds
  #   chmod 400 /home/eugene/.gotty-creds
  #
  # Then enable with:  sudo systemctl start gotty
  # To persist across boots: add `wantedBy = [ "multi-user.target" ];` below.

  systemd.services.gotty = {
    description = "GoTTY — share your terminal as a web application";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    # wantedBy is intentionally omitted — the service is defined but not auto-started.
    # Add `wantedBy = [ "multi-user.target" ];` here when you're ready.

    serviceConfig = {
      User = "nvim";
      Group = "users";
      WorkingDirectory = "/home/nvim";

      LoadCredential = "gotty-password:/home/${settings.username}/.gotty-creds";

      # Copy the static config, then append the credential at runtime.
      # The password never touches the Nix store.
      ExecStartPre = pkgs.writeShellScript "gotty-gen-config" ''
        set -euo pipefail
        CRED="$(cat "$CREDENTIALS_DIRECTORY/gotty-password" | tr -d '\n')"
        cp ${gottyConfigTemplate} /home/nvim/.gotty
        echo "credential = \"$CRED\"" >> /home/nvim/.gotty
        chmod 600 /home/nvim/.gotty
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
