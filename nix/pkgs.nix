{
  nixpkgs,
  system,
  html-greet-frontend,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  frontend = html-greet-frontend.packages.${system}.default;
  wails3 = pkgs.callPackage ./wails3.nix {};
  html-greet = pkgs.callPackage ./package.nix {inherit frontend wails3;};
in {
  default = html-greet;
  wails3 = wails3;
}
