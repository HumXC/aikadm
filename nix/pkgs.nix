{
  nixpkgs,
  system,
  aikadm-frontend,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  lib = import ./lib nixpkgs;
  frontend = aikadm-frontend.packages.${system}.default;
  wails3 = pkgs.callPackage ./wails3.nix {};
  aikadm = pkgs.callPackage ./package.nix {inherit frontend;};
  cmdWithArgs = args: lib.cmdWithArgs ({inherit aikadm;} // args);
in {
  default = aikadm;
  inherit cmdWithArgs wails3;
}
