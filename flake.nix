{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    astal.url = "github:aylur/astal";
  };

  outputs = { self, flake-utils, nixpkgs, ... }@inputs:
    {
      lib = import ./nix/lib self;
    } //
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
        astal = inputs.astal.packages.${system};
      in
      {
        packages = {
          aikadm = pkgs.callPackage ./nix/package.nix {
            astal-greet = astal.greet;
          };
          aikadm-hyprland = self.lib.hyprland-script { inherit pkgs; };
          aikadm-cage = self.lib.cage-script { inherit pkgs; };
        };
        devShells = import ./nix/devshell.nix {
          inherit pkgs astal;
        };
      }
    );
}
