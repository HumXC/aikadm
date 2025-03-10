{
  nixpkgs,
  system,
  frontend,
  ...
}: let
  pkgs = import nixpkgs {inherit system;};
  html-greet = pkgs.callPackage ./package.nix {};
in {
  html-greet = {
    default = html-greet;
    cage-script = args: (import ./lib/cage-script.nix ({inherit pkgs html-greet;} // args));
    hyprland-script = args: (import ./lib/hyprland-script.nix ({inherit pkgs html-greet;} // args));
    frontend = frontend.packages.${system}.default;
  };
}
