# Fleet-wide constants shared by every host. Anything specific to one machine
# (age recipient key, tailscale IP, syncthing ID, username/SSH exceptions) lives
# in hosts/<host>/identity.nix and is aggregated by hosts/default.nix.
let
  self = {
    defaults = {
      username = "basileb";
      ssh.port = 2222;
      gitName = self.people.self.gitName;
      gitEmail = self.people.self.email;
    };

    people = {
      self = self.people.basileb;

      basileb = {
        name = "Basile";
        gitName = "BasileBux";
        email = "basile.buxtorf@ik.me";
        admin = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcVamk9ygIcA/3Q731/O1Yg2gIg7COaEfH1cZqRlymt basile.buxtorf@ik.me";
      };

      kamina = {
        name = "Kamina";
        email = "basileb@nixos";
        admin = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBZdYQlQ4SyaJNlNYRbjOePXhfSFxsudLHjoYQTJ/MR basileb@nixos";
      };
    };

    tailnet.domain = "tail7925e1.ts.net";

    # Endpoints that are not managed NixOS machines (no identity.nix).
    externalHosts.buxtorf-synology.ssh = {
      hostname = "buxtorf-synology.${self.tailnet.domain}";
      port = self.defaults.ssh.port;
      user = "gitt";
    };

    # Admin age co-recipients and authorized_keys entries. Machine keys are not
    # login keys; they are only age recipients.
    keys-admin = map (name: self.people.${name}.key) (
      builtins.filter (name: self.people.${name}.admin or false) (
        builtins.attrNames (builtins.removeAttrs self.people [ "self" ])
      )
    );

    # Syncthing mesh topology (see modules/syncthing.mod.nix). A folder without
    # an explicit `devices` list is shared by every machine that has a
    # `syncthing.id`; per-host sync paths default to "~/<folder-name>".
    syncthing.folders.orgfiles.ignorePatterns = [
      ".git"
      ".jj"
      ".stfolder"
    ];
  };
in
self
