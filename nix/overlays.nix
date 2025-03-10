{
  nixpkgs,
  frontend,
  ...
}: {
  default = final: _prev:
    import ./pkgs.nix {
      inherit nixpkgs frontend;
      system = final.system;
    };
}
