{
  nixpkgs,
  frontend,
  ...
}: {
  default = final: _prev: let
    packages = import ./pkgs.nix {
      inherit nixpkgs frontend;
      system = final.system;
    };
  in {
    html-greet.default = packages.default;
    html-greet.frontend = packages.frontend;
  };
}
