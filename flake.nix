{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    flake-utils,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        html-greet = pkgs.callPackage ./nix/package.nix {};
      in rec {
        lib.hyprland-script = args: (
          import ./nix/lib/hyprland-script.nix ({inherit pkgs html-greet;} // args)
        );
        lib.cage-script = args: (
          import ./nix/lib/cage-script.nix ({inherit pkgs html-greet;} // args)
        );
        packages = {
          inherit html-greet;
          html-greet-hyprland = lib.hyprland-script {};
          html-greet-cage = lib.cage-script {};
        };
        devShells = import ./nix/devshell.nix {inherit pkgs;};
      }
    );
}
