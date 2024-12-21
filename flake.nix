{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    astal.url = "github:aylur/astal";
  };

  outputs = { self, flake-utils, nixpkgs, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        astal = inputs.astal.packages.${system};
      in
      {
        packages.aikadm = pkgs.callPackage ./package.nix {
          astal-greet = astal.greet;
          astal-io = astal.io;
        };
        devShells.default = pkgs.mkShell rec{
          buildInputs = (with pkgs;
            [
              # Build-Tools
              lldb
              pkg-config
              vala
              vala-lint
              meson
              mesonlsp
              ninja
              vala-language-server
              uncrustify
              blueprint-compiler
              sass
              # Dependencies
              gtk4
              gtk4-layer-shell
              gdk-pixbuf
            ]) ++ (with astal;[
            greet
            io
          ]);
          shellHook = ''
            echo "${pkgs.lldb}/bin/lldb-dap"
          '';
        };
      }
    );
}
