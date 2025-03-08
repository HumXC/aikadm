{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = {
          html-greet = pkgs.callPackage ./nix/package.nix {};
          html-greet-hyprland = self.lib.hyprland-script {inherit pkgs;};
          html-greet-cage = self.lib.cage-script {inherit pkgs;};
        };
        devShells = import ./nix/devshell.nix {inherit pkgs;};
      }
    );
}
