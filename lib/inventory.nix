# Based almost verbatim on RGBCube's age/secrets config
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed

{ lib }:
let
  inherit (lib.attrsets) attrValues filterAttrs mapAttrs;
  self = {
    people = {
      self = self.people.basileb;

      basileb = {
        name = "Basile";
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

    # Rekey: `ragenix --rules ./secrets.nix --rekey -i ~/.ssh/simon`
    machines = {
      simon = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiS/gxSDgvtbGGm24jbBeETFD2l83MQaDzmAAq6/p4U simon";
        tailscale.ip = "100.79.180.68";
        syncthing.id = "AIIKEQV-CSX26XH-ULREMP6-F4Z2PZL-TGQ6NTQ-UYPWU4W-OOTK3QU-I3PWXAR";
      };
      kamina = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0w6Y4ZgcSz3fifBDpzB4a4SKgDUT5ZX3CuO8nzXMbR kamina";
        tailscale.ip = "100.100.86.25";
        syncthing.id = "63K5FFQ-V3RZ5O4-3KE7QPP-EDS6TC2-IR56E2U-2NR5MPF-B5MSYGG-S4NVRAW";
      };
      genome = {
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFRkXxChHOwya3tDfztdsgCuovhr1hyMiWDDcMBIlrCn genome";
        tailscale.ip = "100.82.254.103";
        syncthing.id = "ZZ3YA7N-RYW5ZEA-E4FXSR7-2WG5TZH-UEKVQKT-MPQQW5W-KQPUXEN-RAD2IQO";
      };
      yoko.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf/SNZc5Z6bsJ5QlfX1WoWStHADD07uAcXteQ/JTovi yoko";
    };

    sshHosts =
      mapAttrs (name: _: {
        hostname = "${name}.${self.tailnet.domain}";
        port = 2222;
      }) (filterAttrs (_: machine: machine ? tailscale) self.machines)
      // {
        yoko = {
          hostname = "asbel.xyz";
          port = 2222;
          user = "eugene";
        };
        buxtorf-synology = {
          hostname = "buxtorf-synology.${self.tailnet.domain}";
          port = 2222;
          user = "gitt";
        };
      };

    # Syncthing mesh topology (see modules/syncthing.mod.nix). A folder without
    # an explicit `devices` list is shared by every machine that has a
    # `syncthing.id`; per-host sync paths default to "~/<folder-name>".
    syncthing.folders.orgfiles.ignorePatterns = [
      ".git"
      ".jj"
      ".stfolder"
    ];

    keys = mapAttrs (_: { key, ... }: key) (removeAttrs self.people [ "self" ] // self.machines);

    keys-admin =
      removeAttrs self.people [ "self" ]
      |> filterAttrs (
        _:
        {
          admin ? false,
          ...
        }:
        admin
      )
      |> attrValues
      |> map ({ key, ... }: key);
  };
in
self
