{
  nixpkgs,
  system,
  aikadm-frontend,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  frontend = aikadm-frontend.packages.${system}.default;
  wails3 = pkgs.callPackage ./wails3.nix {};
  aikadm = pkgs.callPackage ./package.nix {inherit frontend;};
in {
  default = aikadm;
  wails3 = wails3;
}
