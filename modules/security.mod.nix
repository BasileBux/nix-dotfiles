{ self, lib, ... }: {
  flake.nixosModules.security = { ... }: {
    security.rtkit.enable = true;
    security.sudo.extraConfig = "Defaults pwfeedback";
    security.pam.services.sshd.unixAuth = lib.mkForce true;
  };
}
