{ stdenv
, lib
  # Build-Tools
, lldb
, pkg-config
, vala
, vala-lint
, meson
, mesonlsp
, ninja
, vala-language-server
, uncrustify
, blueprint-compiler
, sass
  # Dependencies
, gtk4
, gtk4-layer-shell
, gdk-pixbuf
, astal-greet
, astal-io
}:

let
in

stdenv.mkDerivation {
  depsBuildBuild = [
    pkg-config
  ];
  nativeBuildInputs = [
    lldb
    vala
    vala-lint
    meson
    mesonlsp
    ninja
    vala-language-server
    uncrustify
    blueprint-compiler
    sass
  ];
  buildInputs = [
    gtk4
    gtk4-layer-shell
    gdk-pixbuf
    astal-greet
    astal-io
  ];
  name = "aikadm";
  src = ./..;
  meta = with lib; {
    homepage = "https://github.com/HumXC/aikadm";
    description = "";
    license = licenses.mit;
  };
}
