{ inputs, pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    interfaces.enp3s0.wakeOnLan.enable = true;
    firewall = {
      allowedUDPPorts = [ 9 ];
    };
  };

  services.power-profiles-daemon.enable = true;

  users.groups.remote-poweroff = { };

  users.users."upsnap-poweroff" = {
    isSystemUser = true;
    group = "remote-poweroff";
    extraGroups = [ "remote-poweroff" ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      ''command="${pkgs.systemd}/bin/systemctl poweroff",no-agent-forwarding,no-port-forwarding,no-X11-forwarding,no-pty,no-user-rc ${inputs.self.serviceKeys.upsnap}''
    ];
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var allowedActions = [
        "org.freedesktop.login1.power-off",
        "org.freedesktop.login1.power-off-multiple-sessions"
      ];

      if (subject.isInGroup("remote-poweroff") &&
          allowedActions.indexOf(action.id) !== -1) {
        return polkit.Result.YES;
      }
    });
  '';
}
