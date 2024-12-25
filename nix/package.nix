{ stdenv
, lib
, makeWrapper
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
, astal-greet
, librsvg
}:

let
in

stdenv.mkDerivation {
  depsBuildBuild = [
    pkg-config
  ];
  nativeBuildInputs = [
    makeWrapper
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
    astal-greet
  ];
  installPhase = ''
    runHook preInstall
    unset GDK_PIXBUF_MODULE_FILE
    findGdkPixbufLoaders "${librsvg}"

    mkdir -p $out/bin
    cp src/aikadm $out/bin/.aikadm-unwrapped
    echo $GDK_PIXBUF_MODULE_FILE
    makeWrapper $out/bin/.aikadm-unwrapped $out/bin/aikadm \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"

    runHook postInstall
  '';
  name = "aikadm";
  src = ./..;
  meta = with lib; {
    homepage = "https://github.com/HumXC/aikadm";
    description = "";
    license = licenses.gpl3;
  };
}
