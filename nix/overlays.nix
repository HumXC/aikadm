{
  nixpkgs,
  html-greet-frontend,
  ...
}: {
  default = final: _prev: let
    packages = import ./pkgs.nix {
      inherit nixpkgs html-greet-frontend;
      system = final.system;
    };
  in {
    html-greet = packages.default;
  };
}
