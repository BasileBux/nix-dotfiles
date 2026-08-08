{
  self,
  ...
}:
{
  flake.nixosModules.desktop = self.nixosModules.libvirtd;
  flake.nixosModules.libvirtd = { config, lib, ... }: {
    options.my.virtualisation.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable virtualisation (libvirtd, virt-manager, KVM). Reboot after toggling.";
    };

    config = lib.mkIf config.my.virtualisation.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      users.users.${config.my.settings.username}.extraGroups = [
        "libvirt"
        "kvm"
      ];
    };
  };
}
