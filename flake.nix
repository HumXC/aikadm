{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    aikadm-frontend.url = "github:HumXC/aikadm-frontend";
    aikadm-frontend.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    aikadm-frontend,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in
    {
      lib = import ./nix/lib nixpkgs;
    }
    // {
      overlays = import ./nix/overlays.nix {inherit nixpkgs aikadm-frontend;};
      packages = forAllSystems (system: import ./nix/pkgs.nix {inherit nixpkgs system aikadm-frontend;});
      devShells = forAllSystems (system: import ./nix/devshell.nix {inherit nixpkgs system;});
    };
  nixConfig = {
    # substituers will be appended to the default substituters when fetching packages
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
