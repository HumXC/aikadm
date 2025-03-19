{
  nixpkgs,
  aikadm-frontend,
  ...
}: {
  default = final: _prev: let
    packages = import ./pkgs.nix {
      inherit nixpkgs aikadm-frontend;
      system = final.system;
    };
  in {
    aikadm = packages.default;
  };
}
