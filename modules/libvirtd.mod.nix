{ self, config, ... }: {
  flake.nixosModules.desktop = self.nixosModules.libvirtd;
  flake.nixosModules.libvirtd = { config, ... }: {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
    users.users.${config.my.settings.username}.extraGroups = [
      "libvirt"
      "kvm"
    ];
  };
}
