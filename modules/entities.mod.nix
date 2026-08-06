# Based almost verbatim on RGBCube's age/secrets config
# from https://github.com/RGBCube/ncc/tree/dentride
# Copyright (c) 2023-present RGBCube, MIT licensed

{ self, lib, ... }:
let
  inherit (lib.attrsets) attrValues filterAttrs mapAttrs;
in
{
  flake.people = {
    self = self.people.basileb;

    basileb = {
      name = "Basile";
      email = "basile.buxtorf@ik.me";
      admin = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiS/gxSDgvtbGGm24jbBeETFD2l83MQaDzmAAq6/p4U simon";
    };
  };

  flake.machines = {
    simon.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiS/gxSDgvtbGGm24jbBeETFD2l83MQaDzmAAq6/p4U simon";
    yoko.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf/SNZc5Z6bsJ5QlfX1WoWStHADD07uAcXteQ/JTovi yoko";
  };

  # All keys merged: people + machines
  flake.keys = mapAttrs (_: { key, ... }: key) (removeAttrs self.people [ "self" ] // self.machines);

  # Admin-only keys (for host secrets: host key + admin keys)
  flake.keys-admin =
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
}
