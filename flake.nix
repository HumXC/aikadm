{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    html-greet-frontend.url = "github:HumXC/html-greet-frontend";
    html-greet-frontend.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    html-greet-frontend,
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
      overlays = import ./nix/overlays.nix {inherit nixpkgs html-greet-frontend;};
      packages = forAllSystems (system: import ./nix/pkgs.nix {inherit nixpkgs system html-greet-frontend;});
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
