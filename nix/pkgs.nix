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
  aikadm-dev = pkgs.callPackage ./package.nix {
    inherit frontend;
    debug = true;
  };
  cmdWithArgs = args: lib.cmdWithArgs ({inherit aikadm;} // args);
in {
  default = aikadm;
  dev = aikadm-dev;
  inherit cmdWithArgs wails3;
}
