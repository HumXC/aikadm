{
  nixpkgs,
  system,
  frontend,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  html-greet = pkgs.callPackage ./package.nix {};
in {
  default = html-greet;
  frontend = frontend.packages.${system}.default;
}
