{
  flake.module.libvirtd = {
    nixos = { config, lib, ... }: {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      users.users.${config.my.settings.username}.extraGroups = [
        "libvirt"
        "kvm"
      ];
    };
  };
}
