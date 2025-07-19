let
  megalinee = import ./megalinee.nix;
in {
  background = megalinee.bg0;
  text = megalinee.fg1;
  border = megalinee.bg3;
  selected = megalinee.bg2;
}
