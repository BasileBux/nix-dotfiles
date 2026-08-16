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
    kamina.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0w6Y4ZgcSz3fifBDpzB4a4SKgDUT5ZX3CuO8nzXMbR kamina";
    yoko.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf/SNZc5Z6bsJ5QlfX1WoWStHADD07uAcXteQ/JTovi yoko";
  };

  # Service keys are public SSH keys used by narrowly-scoped service accounts.
  # Keep these separate from `flake.keys`: the latter are age recipients for
  # NixOS secrets, while service keys must not receive any secrets.
  flake.serviceKeys = {
    upsnap = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKeX4nTrwIVVV5rWbqOqwqZDMtmmw3wHUN7JN308PIP upsnap@raspberrypi";
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
