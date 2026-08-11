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
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcVamk9ygIcA/3Q731/O1Yg2gIg7COaEfH1cZqRlymt basile.buxtorf@ik.me";
    };
  };

  # Rekey: `ragenix --rules ./secrets.nix --rekey -i ~/.ssh/simon`
  flake.machines = {
    simon.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINiS/gxSDgvtbGGm24jbBeETFD2l83MQaDzmAAq6/p4U simon";
    kamina.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVn7PQ92L1HYVvnEZ5D2yG6i3YhSzVCxu8NoJmf0g8S kamina";
    yoko.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf/SNZc5Z6bsJ5QlfX1WoWStHADD07uAcXteQ/JTovi yoko";
  };

  flake.keys = mapAttrs (_: { key, ... }: key) (removeAttrs self.people [ "self" ] // self.machines);

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
