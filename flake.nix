{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in {
    overlays = import ./nix/overlays.nix;
    packages = forAllSystems (system: import ./nix/pkgs.nix {inherit nixpkgs system;});
    devShells = forAllSystems (system: import ./nix/devshell.nix {inherit nixpkgs system;});
  };
}
