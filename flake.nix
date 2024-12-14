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
        devShells.default = pkgs.mkShell rec{
          buildInputs = with pkgs; [
            pkg-config
            vala
            vala-lint
            meson
            ninja
            mesonlsp
            vala-language-server
            gst
            uncrustify
            gtk4
            glib
            gtk4-layer-shell
          ] ++ (with astal;[
            greet
          ]);
          shellHook = ''
            export PKG_CONFIG_PATH=$(pkg-config --variable pc_path pkg-config)
          '';
        };
      }
    );
}
