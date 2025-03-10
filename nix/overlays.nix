{
  default = final: _prev: import ./pkgs.nix {pkgs = final.pkgs;};
}
