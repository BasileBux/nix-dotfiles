{ self, ... }: {
  flake.nixosModules.desktop = self.nixosModules.libvirtd;
  flake.nixosModules.libvirtd = { ... }: {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;
  };
}
