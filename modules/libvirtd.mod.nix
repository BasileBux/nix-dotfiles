# libvirtd/QEMU/KVM, split for remote usage:
#   my.libvirtd.enable       — host runs the VMs
#   my.libvirtd.subnetRouter — advertise the VM NAT subnet over tailscale
#   my.libvirtd.remoteUris   — manage remote VM hosts with virt-manager (consoles
#                              are tunnelled over SSH, so it works over tailscale)
{ self, ... }: {
  flake.module.libvirt-host = {
    imports = [ self.flakeModules.libvirtd ];
    nixos.my.libvirtd.enable = true;
  };
  flake.module.libvirt-client = {
    imports = [ self.flakeModules.libvirtd ];
    nixos.my.libvirtd.client.enable = true;
  };
  flake.module.libvirt-router = {
    imports = [
      self.flakeModules.libvirt-host
      self.flakeModules.tailscale
    ];
    nixos.my.libvirtd.subnetRouter.enable = true;
  };
  flake.module.libvirtd = {
    imports = [ self.flakeModules.tailscale-options ];
    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options.my.libvirtd = {
          enable = lib.mkEnableOption "running virtual machines with libvirtd/QEMU/KVM";

          subnetRouter.enable = lib.mkEnableOption ''
            advertising the libvirt NAT subnet (192.168.122.0/24) over tailscale
          '';

          client.enable = lib.mkEnableOption "the virt-manager client";
          remoteUris = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            example = [ "qemu+ssh://kamina/system" ];
            description = ''
              libvirt URIs of remote VM hosts to manage with virt-manager.
              Non-empty enables virt-manager and pre-registers the connections.
            '';
          };
        };

        config = lib.mkMerge [
          {
            assertions = [
              {
                assertion =
                  !config.my.libvirtd.subnetRouter.enable
                  || (config.my.libvirtd.enable && config.services.tailscale.enable);
                message = "Libvirt subnet routing requires both the VM host and Tailscale roles.";
              }
            ];
          }
          (lib.mkIf config.my.libvirtd.enable {
            virtualisation.libvirtd.enable = true;
            virtualisation.libvirtd.qemu.swtpm.enable = true; # TPM 2.0 for Windows 11
            virtualisation.spiceUSBRedirection.enable = true;

            # Recent libvirt gates qemu:///system behind polkit, and there is no
            # polkit agent over SSH — grant the group explicitly instead.
            users.groups.libvirt = { };
            users.users.${config.my.settings.username}.extraGroups = [
              "libvirt"
              "kvm"
            ];
            security.polkit.extraConfig = ''
              polkit.addRule(function(action, subject) {
                if (action.id == "org.libvirt.unix.manage"
                    && subject.isInGroup("libvirt")) {
                  return polkit.Result.YES;
                }
              });
            '';
          })

          (lib.mkIf config.my.libvirtd.subnetRouter.enable {
            services.tailscale.useRoutingFeatures = lib.mkOverride 900 "server";
            my.tailscale.routes = [ "192.168.122.0/24" ];

            # libvirt installs a FORWARD REJECT rule for traffic entering
            # virbr0 from any other interface, which drops packets that
            # tailscale clients route to the VM NAT subnet. Allow them
            # explicitly, inserted before libvirtd adds its own rules.
            systemd.services.libvirtd-subnet-router-forward = {
              description = "Allow tailscale clients to reach the libvirt NAT network";
              wantedBy = [ "multi-user.target" ];
              before = [ "libvirtd.service" ];
              after = [ "network-pre.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.iptables}/bin/iptables -t filter -I FORWARD 1 -i tailscale0 -o virbr0 -j ACCEPT";
                ExecStop = "${pkgs.iptables}/bin/iptables -t filter -D FORWARD -i tailscale0 -o virbr0 -j ACCEPT";
              };
            };
          })

          (lib.mkIf (config.my.libvirtd.client.enable || config.my.libvirtd.remoteUris != [ ]) {
            # Install directly: the upstream module adds a competing dconf database.
            environment.systemPackages = [
              pkgs.virt-manager
              pkgs.virt-viewer
            ];
            programs.dconf.enable = true;
            programs.dconf.profiles.user.databases = [
              {
                settings = {
                  "org/virt-manager/virt-manager/connections" = {
                    uris = [ "qemu:///system" ] ++ config.my.libvirtd.remoteUris;
                    autoconnect = [ "qemu:///system" ];
                  };
                };
              }
            ];
          })
        ];
      };
  };
}
