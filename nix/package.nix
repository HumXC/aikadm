{
  lib,
  frontend,
  makeWrapper,
  pkg-config,
  buildGoModule,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  webkitgtk_4_1,
  cage,
  debug ? false,
}:
buildGoModule {
  pname = "aikadm";
  version = "0.0.1";

  src = ./..;

  vendorHash = "sha256-Wy4G0rmalykYhbYCzPYjscyvYxU5NMWvxiaHcp1Lb78=";
  nativeBuildInputs = [makeWrapper pkg-config];
  proxyVendor = true;
  allowGoReference = true;
  buildInputs = [webkitgtk_4_1];
  tags =
    [
      "desktop"
      "production"
    ]
    ++ (lib.optional debug ["debug" "devtools"]);
  ldflags = [
    "-s"
    "-w"
  ];
  preBuild = ''
    mkdir frontend
    cp -r ${frontend}/share/aikadm-frontend/* frontend/
  '';
  # https://wails.io/docs/guides/nixos-font/
  postFixup = ''
    wrapProgram $out/bin/aikadm \
      --prefix PATH : "${cage}/bin" \
      --set XDG_DATA_DIRS ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS \
      --set GIO_MODULE_DIR ${glib-networking}/lib/gio/modules/
  '';
  meta = {
    description = "Build display manager using HTML + CSS + JS";
    homepage = "https://github.com/HumXC/aikadm";
    license = lib.licenses.mit;
    mainProgram = "aikadm";
    platforms = lib.platforms.unix;
  };
}
