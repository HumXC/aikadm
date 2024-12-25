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
      rec {
        packages.aikadm = pkgs.callPackage ./nix/package.nix {
          astal-greet = astal.greet;
        };
        packages.aikadm-hyprland = lib.aikadm-hyprland-script {
          defaultSession = "Hyprland";
          debug = true;
        };
        lib = {
          aikadm-hyprland-script = (args: (import ./nix/aikadm-hyprland-script.nix
            ({
              inherit pkgs;
              aikadm = packages.aikadm;
            } // args)
          ));
        };
        devShells.default = pkgs.mkShell {
          buildInputs =
            (with pkgs;[
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
              librsvg
            ]) ++ (with astal;[
              greet
            ]);
          shellHook = ''
            echo "${pkgs.lldb}/bin/lldb-dap"
          '';
        };
      }
    );
}
